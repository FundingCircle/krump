require 'spec_helper'
require 'krump/config_parser'


module Krump
  describe ConfigParser do
    CONFIG_FILE = '/tmp/krump_test_config'

    describe '#parse' do
      subject(:parser) { ConfigParser.new(CONFIG_FILE, 'rspec') }

      it 'parses the gateway host' do
        File.open(CONFIG_FILE, 'w') do |fh|
          fh.puts 'rspec.gateway_host=bastion'
        end
        config = parser.parse

        expect(config[:gateway_host]).to eq('bastion')
      end

      it 'handles multiple environments' do
        File.open(CONFIG_FILE, 'w') do |fh|
          fh.puts 'rspec.gateway_host=bastion'
          fh.puts 'other.gateway_host=bastion'
        end
        config = parser.parse

        expect(config[:gateway_host]).to eq('bastion')
      end

      it 'parses the gateway credentials' do
        File.open(CONFIG_FILE, 'w') do |fh|
          fh.puts 'rspec.gateway_hostname=my.host.com'
          fh.puts 'rspec.gateway_user=my-user'
          fh.puts 'rspec.gateway_identityfile=my-key.pem'
        end
        config = parser.parse

        expect(config[:gateway_hostname]).to eq('my.host.com')
        expect(config[:gateway_user]).to eq('my-user')
        expect(config[:gateway_identityfile]).to eq('my-key.pem')
      end

      it 'parses kafka broker' do
        File.open(CONFIG_FILE, 'w') do |fh|
          fh.puts 'rspec.kafka_broker=kafka:9092'
        end
        broker = parser.parse[:brokers].first

        expect(broker).to eq('kafka:9092')
      end

      it 'parses multiple kafka brokers' do
        File.open(CONFIG_FILE, 'w') do |fh|
          fh.puts 'rspec.kafka_broker=kafka0:9092'
          fh.puts 'rspec.kafka_broker=kafka1:9092'
          fh.puts 'rspec.kafka_broker=kafka2:9092'
        end
        config = parser.parse

        config[:brokers].each_with_index do |broker, i|
          expect(broker).to eq("kafka#{i}:9092")
        end
        expect(config[:ssh_tunnel_info].size).to eq(0)
      end

      it 'parses kafka broker with ssh tunnel info' do
        File.open(CONFIG_FILE, 'w') do |fh|
          fh.puts 'rspec.kafka_broker=kafka:9092,9093'
        end
        config = parser.parse

        broker = config[:brokers].first
        expect(broker).to eq('kafka:9092')

        info = config[:ssh_tunnel_info].first
        expect(info.host).to eq('kafka')
        expect(info.port).to eq(9092)
        expect(info.local_port).to eq(9093)
      end

      it 'parses multiple kafka brokers with ssh tunnel info' do
        File.open(CONFIG_FILE, 'w') do |fh|
          fh.puts 'rspec.kafka_broker=kafka0:9092,9093'
          fh.puts 'rspec.kafka_broker=kafka1:9092,9094'
          fh.puts 'rspec.kafka_broker=kafka2:9092,9095'
        end
        config = parser.parse

        brokers = config[:brokers]
        brokers.each_with_index do |broker, i|
          expect(broker).to eq("kafka#{i}:9092")
        end

        tunnel_info = config[:ssh_tunnel_info]
        tunnel_info.each_with_index do |info, i|
          expect(info.host).to eq("kafka#{i}")
          expect(info.port).to eq(9092)
          expect(info.local_port).to eq(9093 + i)
        end
      end

      it 'parses a mix of brokers with and without ssh tunnel info' do
        File.open(CONFIG_FILE, 'w') do |fh|
          fh.puts 'rspec.kafka_broker=kafka0:9092'
          fh.puts 'rspec.kafka_broker=kafka1:9092,9093'
        end
        config = parser.parse

        brokers = config[:brokers]
        brokers.each_with_index do |broker, i|
          expect(broker).to eq("kafka#{i}:9092")
        end

        info = config[:ssh_tunnel_info].first
        expect(info.host).to eq('kafka1')
        expect(info.port).to eq(9092)
        expect(info.local_port).to eq(9093)
      end

      it 'fails if an unsupported config option is set' do
        File.open(CONFIG_FILE, 'w') do |fh|
          fh.puts 'rspec.unsupported=foobar'
        end
        expect { parser.parse }.to raise_error(RuntimeError)
      end

      it 'fails if environment is not in config' do
        File.open(CONFIG_FILE, 'w') do |fh|
        end
        expect { parser.parse }.to raise_error(RuntimeError)

        File.open(CONFIG_FILE, 'w') do |fh|
          fh.puts 'not_rspec.gateway_host'
        end
        expect { parser.parse }.to raise_error(RuntimeError)
      end

      it 'fails if both host and hostname is set' do
        File.open(CONFIG_FILE, 'w') do |fh|
          fh.puts 'rspec.gateway_host=bastion'
          fh.puts 'rspec.gateway_hostname=my.host.com'
        end
        expect { parser.parse }.to raise_error(RuntimeError)
      end

      it 'fails if a credential is set, but not all credentials are set' do
        credentials = [
          'rspec.gateway_hostname=my.host.com',
          'rspec.gateway_user=my-user',
          'rspec.gateway_identityfile=my-key.pem'
        ]

        combinations = (1..2).flat_map { |size| credentials.combination(size).to_a }

        combinations.each do |combo|
          File.open(CONFIG_FILE, 'w') do |fh|
            fh.puts combo.join("\n")
          end
          expect { parser.parse }.to raise_error(RuntimeError)
        end
      end
    end
  end
end
