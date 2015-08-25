require 'net/ssh/gateway'


module Krump
  class SshTunnels

    def initialize(gateway_hostname, gateway_user, gateway_identityfile, ssh_tunnel_info)
      @gateway_hostname = gateway_hostname
      @gateway_user = gateway_user
      @gateway_identityfile = gateway_identityfile
      @ssh_tunnel_info = Array(ssh_tunnel_info)
    end

    def open(&block)
      block_given? ? open_with_block(&block) : open_without_block
    end

    private

    def open_with_block(&block)
      gateway = open_without_block
      yield gateway
    ensure
      gateway.shutdown! unless gateway.nil?
    end

    def open_without_block
      gateway = Net::SSH::Gateway.new(
        @gateway_hostname,
        @gateway_user,
        :keys => [@gateway_identityfile]
      )

      @ssh_tunnel_info.each do |info|
        gateway.open(info.host, info.port, info.local_port)
      end

      gateway
    end
  end
end
