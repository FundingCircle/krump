require 'socket'

module Krump
  class LocalOpenPort

    # Return an open port from the ephemeral port range
    def self.find
      socket = Socket.new(:INET, :STREAM, 0)
      socket.bind(Addrinfo.tcp("127.0.0.1", 0))
      socket.local_address.ip_port
    end
  end
end
