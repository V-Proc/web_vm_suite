# frozen_string_literal: true

require "socket"
require "websocket"

module Vms
  module WsProxy
    # Минималистичный TCP<->WebSocket мост для noVNC.
    # Слушает один WS-порт; на каждый апгрейд по токену находит хост/порт
    # VNC-дисплея (Router) и перекачивает байты в обе стороны.
    class Server
      def initialize(port:, router:, logger: Rails.logger, io_server: nil)
        @port = port
        @router = router
        @logger = logger
        @io_server = io_server || ->(own_port) { TCPServer.new(own_port) }
        @threads = []
      end

      def run
        loop do
          client = begin
            @io_server.call(@port).accept
          rescue StandardError, IOError
            next
          end
          @threads << Thread.new(client) { |socket| handle(socket) }
        end
      ensure
        @threads.each { |t| t.join(1) }
      end

      # Строка ответа на HTTP Upgrade (для юнит-тестов).
      def self.handshake_response(accept_key)
        <<~RESPONSE
          HTTP/1.1 101 Switching Protocols\r
          Upgrade: websocket\r
          Connection: Upgrade\r
          Sec-WebSocket-Accept: #{accept_key}\r
          \r
        RESPONSE
      end

      private

      def handle(socket)
        request = socket.gets("\r\n\r\n") || socket.read
        target = @router.target_for(token_from(request))

        unless target
          socket.write("HTTP/1.1 403 Forbidden\r\nContent-Length: 0\r\n\r\n")
          socket.close
          return
        end

        handshake = JSONHttpHandshake.new(request.to_s)
        socket.write(handshake.response)

        upstream = TCPSocket.new(target[:host], target[:port])
        pump(socket, upstream, handshake.version)
      rescue StandardError => e
        @logger.error("[WsProxy] #{e.class}: #{e.message}")
      ensure
        socket.close unless socket.closed?
      end

      def token_from(request)
        request[/token=([a-zA-Z0-9-]+)/, 1]
      end

      def pump(client, upstream, version)
        inbound = WebSocket::Frame::Incoming::Server.new(version: version)
        loop do
          ready = IO.select([client, upstream])
          next unless ready

          ready[0].each do |io|
            if io.eql?(client)
              feed_client_bytes(inbound, io, upstream)
            else
              client.write(out_frame(read_blob(io), version))
            end
          end
        end
      end

      def feed_client_bytes(inbound, client, upstream)
        inbound << read_blob(client)
        while (msg = inbound.next)
          upstream.write(msg)
        end
      end

      def read_blob(io)
        io.read_nonblock(65_536)
      rescue IO::WaitReadable
        nil
      end

      def out_frame(data, version)
        WebSocket::Frame::Outgoing::Server
          .new(version: version, data: data, type: :binary)
          .to_s
      end

      class JSONHttpHandshake
        def initialize(request)
          @hs = WebSocket::Handshake::Server.new
          @hs << request
        end

        def response = @hs.to_s

        def version = @hs.version
      end
    end
  end
end
