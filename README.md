# Krump

A Kafka consumer focused on convenience.

This application was written because of a need for a `tail`-like way to consume Kafka messages. `kafka-console-consumer.sh`, which is distributed with Kafka, allows you to either read _all_ messages in a topic, or any _new_ message. However, most often I want to to see the most recent few messages from a topic.

`krump` provides that as well as a number of other conveniences.

## Feature Overview

1. See the most recent `n` messages in a topic
2. See a specific range of messages
3. See messages from specific partitions
4. Get a count of messages for a particular topic/partition
5. Automatically set up SSH tunnels so it can be run locally

## Installation

    $ git clone git@github.com:FundingCircle/krump.git
    $ cd krump
    $ gem build krump.gemspec
    $ gem install krump-0.2.0.gem

## Usage

Here are some examples on how to use the application. In these examples no broker information is given so it just connects to `localhost:9092`.

**See the most recent 2 messages from the topic `sometopic`:**

```bash
$ krump --topic sometopic --offset -2
===== Topic: sometopic = Partition: 0 =======
{"id":"111"}
{"id":"222"}
===== Topic: sometopic = Partition: 1 =======
{"id":"333"}
{"id":"444"}
===== Topic: sometopic = Partition: 2 =======
{"id":"555"}
{"id":"666"}
===== Topic: sometopic = Partition: 3 =======
{"id":"777"}
{"id":"888"}
```

**See 3 messages starting at offset 100 on partitions 1 & 2:**

```bash
$ krump --topic sometopic --partitions 1 2 --offset 100 --read-count 3
===== Topic: sometopic = Partition: 0 =======
{"id":"123"}
{"id":"456"}
{"id":"789"}
===== Topic: sometopic = Partition: 1 =======
{"id":"abc"}
{"id":"def"}
{"id":"fff"}
```

**Show how many messages are in each partition:**

```bash
$ krump --topic sometopic --count-messages
sometopic | Partition 0 | 29043 messages
sometopic | Partition 1 | 29776 messages
sometopic | Partition 2 | 29118 messages
sometopic | Partition 3 | 27406 messages
```

Use `krump --help` to see all options.

### Config File

You can set configurations for different environments in the config file (`~/.krump` by default).

This is especially useful if your cluster is behind a gateway server (e.g. an AWS VPC).

Example config file:

    # Directly access a Kafka cluster on the Internet
    dev.kafka_broker=51.120.33.24:9092

    # Or connect to a Kafka cluster behind a gateway server
    staging.gateway_hostname=51.150.99.142
    staging.gateway_user=ec2-user
    staging.gateway_identityfile=~/.ssh/mykey.pem
    staging.kafka_broker=10.0.100.1:9092
    staging.kafka_broker=10.0.100.2:9092
    staging.kafka_broker=10.0.100.3:9092

    # You can also use a host alias and it will get the connection info from
    # /etc/ssh/config or ~/.ssh/config
    uat.gateway_host=uat-bastion
    uat.kafka_broker=10.0.105.1:9092
    uat.kafka_broker=10.0.105.2:9092
    uat.kafka_broker=10.0.105.3:9092

Use the `--environment` flag to use the connection settings for that environment, for example:

```bash
$ krump --environment staging --topic sometopic --latest-offset
```

If an environment's settings include gateway particulars, `krump` will handle setting up temporary SSH tunnels.


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).


## Contributing

1. Fork it ( https://github.com/[my-github-username]/krump/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
