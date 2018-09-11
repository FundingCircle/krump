# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'krump/version'

Gem::Specification.new do |spec|
  spec.name          = 'krump'
  spec.version       = Krump::VERSION
  spec.authors       = ['Dean Morin']
  spec.email         = ['dean.morin@fundingcircle.com']

  spec.summary       = %q{A Kafka consumer focused on convenience.}
  spec.description   = %q{This application was written because of a need for a tail-like way to consume Kafka messages. kafka-console-consumer.sh, which is distributed with Kafka, allows you to either read all messages in a topic, or any new message. However, most often I want to to see the most recent few messages from a topic. Krump provides that as well as a number of other conveniences.
}
  spec.homepage      = 'https://github.com/fundingcircle/krump'
  spec.license       = 'BSD 3-Clause'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = 'krump'
  spec.require_paths = ['lib']

  spec.add_dependency 'net-ssh-gateway', '~> 1.2'
  spec.add_dependency 'poseidon', '0.0.5'
  spec.add_dependency 'trollop', '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.9'
  spec.add_development_dependency 'pry', '>= 0.10.1'
  spec.add_development_dependency 'rake', '~> 12.3'
  spec.add_development_dependency 'rspec', '~> 3.3'

  spec.required_ruby_version = '>= 2.0.0'
end
