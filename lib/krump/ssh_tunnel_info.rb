module Krump
  class SshTunnelInfo
    attr_accessor :host, :port, :local_port

    def initialize(host, port, local_port)
      @host = host
      @port = port.to_i
      @local_port = local_port.to_i
    end
  end
end
