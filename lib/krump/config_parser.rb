require 'krump/local_open_port'
require 'krump/ssh_tunnel_info'


module Krump
  class ConfigParser

    def initialize(filename, environment)
      @filename =
        if !filename.nil? && filename.start_with?('~/')
          "#{Dir.home}/#{filename.split('/', 2).last}"
        else
          filename
        end
      @environment = environment
    end

    def parse
      if @filename && @environment
        File.open(@filename, 'r') { |fh| parse_config(fh.readlines) }
      else
        {}
      end
    rescue Errno::ENOENT => e
      # Ignore file-not-found error if it's the default filename
      raise unless @filename == default_config
      {}
    rescue StandardError => e
      STDERR.puts 'There is an error in your config file'
      raise
    end

    private

    def parse_config(lines)
      lines.keep_if { |line| line.start_with?(@environment) }

      if lines.empty?
        fail "No configuration for environment '#{@environment}'"
      end

      config = {}
      config[:brokers] = []
      config[:ssh_tunnel_info] = []

      lines.each do |line|
        key = line.split("#{@environment}.").last.split('=').first
        value = line.split('=').last.chomp

        case key
        when 'gateway_host'         then config[:gateway_host] = value
        when 'gateway_hostname'     then config[:gateway_hostname] = value
        when 'gateway_user'         then config[:gateway_user] = value
        when 'gateway_identityfile' then config[:gateway_identityfile] = value
        when 'kafka_broker'         then add_broker_to_config!(config, value)
        else
          fail "#{key} is not a supported config option"
        end
      end

      fail_if_invalid_config(config)
      config
    end

    def add_broker_to_config!(config, value)
      host = value.split(':').first
      port = value.split(':').last

      if broker_behind_gateway?(config)
        local_port = LocalOpenPort.find
        config[:ssh_tunnel_info] << SshTunnelInfo.new(host, port, local_port)
        config[:brokers] << "localhost:#{local_port}"
      else
        config[:brokers] << "#{host}:#{port}"
      end
    end

    def broker_behind_gateway?(config)
      config[:gateway_host] || config[:gateway_hostname]
    end

    def fail_if_invalid_config(config)
      fail_if_incompatible_settings(config[:gateway_host], config[:gateway_hostname])
      fail_if_incompatible_settings(config[:gateway_host], config[:gateway_user])
      fail_if_incompatible_settings(config[:gateway_host], config[:gateway_identityfile])

      gateway_credential_keys = [:gateway_hostname, :gateway_user, :gateway_identityfile]

      if gateway_credential_keys.any? { |key| config[key] }
        unless gateway_credential_keys.all? { |key| config[key] }
          fail "If any of (#{gateway_credential_keys.join(',')}) are set then all need to be set"
        end
      end
    end

    def fail_if_incompatible_settings(setting1, setting2)
      fail "Both #{setting1} and #{setting2} cannot be set" if setting1 && setting2
    end

    def default_config
      "#{Dir.home}/.krump"
    end
  end
end
