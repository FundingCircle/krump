require 'poseidon'


module Krump
  class KafkaConsumer
    attr_accessor :messages_read
    attr_reader :broker, :consumer, :last_fetch_size, :offset, :partition, :topic

    def initialize(brokers, topic, partition, offset)
      @topic = topic
      @partition = partition
      @offset = offset
      @broker = find_broker_for_partition_or_fail(brokers.clone)
      @consumer = init_consumer
      @messages_read = 0
      @last_fetch_size = 0
    end

    def fetch
      messages = @consumer.fetch
      @last_fetch_size = messages.size
      messages
    end

    private

    # Poseiden expects that you know which broker to find a particular
    # partition on. This method simply tries them all. Errors are silently ignored,
    # unless all brokers are checked and the requested topic/partition is still
    # not found.
    #
    # It uses a negative offset because a positive one won't fail on consumer.next_offset.
    #
    def find_broker_for_partition_or_fail(brokers)
      broker = brokers.shift
      host = broker.split(':').first
      port = broker.split(':').last

      consumer = Poseidon::PartitionConsumer.new(
        "krump-kafka-test-consumer_#{@topic}_#{@partition}_#{DateTime.now}",
        host,
        port,
        @topic,
        @partition,
        -1
      )
      consumer.next_offset
      consumer.close

      broker

    rescue Poseidon::Errors::NotLeaderForPartition => e
      retry if brokers.size > 0
      raise e
    rescue Poseidon::Errors::UnknownTopicOrPartition => e
      retry if brokers.size > 0
      raise e
    end

    def init_consumer
      host = @broker.split(':').first
      port = @broker.split(':').last

      consumer = Poseidon::PartitionConsumer.new(
        "krump-kafka-consumer_#{@topic}_#{@partition}_#{DateTime.now}",
        host,
        port,
        @topic,
        @partition,
        @offset
      )
      consumer
    end
  end
end
