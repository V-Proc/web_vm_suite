# frozen_string_literal: true

require "test_helper"
require "minitest/mock"
require "socket"
require "websocket"

module Vms
  class WsProxyServerTest < ActiveSupport::TestCase
    HANSHAKE_REQUEST = <<~REQ
      GET /websockify?host=127.0.0.1&port=0&token=11111111-2222-3333-4444-555555555555 HTTP/1.1\r
      Host: localhost\r
      Upgrade: websocket\r
      Connection: Upgrade\r
      Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==\r
      Sec-WebSocket-Version: 13\r
      \r
    REQ

    test "handshake считается по RFC 6455 (пример из спеки)" do
      accept = Base64.strict_encode64(
        Digest::SHA1.digest("dGhlIHNhbXBsZSBub25jZQ==258EAFA5-E914-47DA-95CA-C5AB0DC85B11")
      )
      response = Vms::WsProxy::Server.handshake_response(accept)

      assert_includes response, "101 Switching Protocols"
      assert_includes response, "Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo="
    end

    test "клиент с невалидным токеном получает 403" do
      request = HANSHAKE_REQUEST.sub("token=11111111-2222-3333-4444-555555555555", "token=unknown")
      router = Minitest::Mock.new
      router.expect(:target_for, nil, ["unknown"])

      with_ws_server(router) do |ws_port|
        client = TCPSocket.new("127.0.0.1", ws_port)
        client.write(request)
        response = client.read(4096)

        assert_includes response, "403 Forbidden"
        client.close
      end
    end

    test "валидный handshake и данные уходят в обе стороны" do
      with_fake_vnc do |vnc|
        router = Minitest::Mock.new
        router.expect(:target_for,
                      { host: "127.0.0.1", port: vnc.port, vm: nil },
                      ["11111111-2222-3333-4444-555555555555"])

        with_ws_server(router) do |ws_port|
          client = TCPSocket.new("127.0.0.1", ws_port)
          client.write(HANSHAKE_REQUEST)
          response = client.readpartial(4096)

          assert_includes response, "101 Switching Protocols"

          frame = WebSocket::Frame::Outgoing::Client
                    .new(version: 13, data: "пинг", type: :text)
          client.write(frame.to_s)

          deadline = 2.0
          until vnc.received.b.include?("пинг".b) || deadline <= 0
            sleep 0.05
            deadline -= 0.05
          end

          assert_includes vnc.received.b, "пинг".b

          reply = WebSocket::Frame::Incoming::Client.new(version: 13)
          reply << client.readpartial(4096)
          assert_equal "ok", reply.next.data

          client.close
        end
      end
    end

    private

    def with_ws_server(router)
      listener = TCPServer.new("127.0.0.1", 0)
      port = listener.addr[1]
      server = Vms::WsProxy::Server.new(port: port, router: router, io_server: ->(p) { listener })

      thread = Thread.new { server.run }
      yield port
    ensure
      listener.close unless listener.closed?
      thread.join(1) if thread
    end

    FakeVnc = Struct.new(:port, :received, :server) do
      def stop
        server.close unless server.closed?
      end
    end

    def with_fake_vnc
      front = TCPServer.new("127.0.0.1", 0)
      port = front.addr[1]
      received = +""

      thread = Thread.new do
        loop do
          socket = front.accept
          socket.write("ok")
          received << (socket.readpartial(4096) || "")
          socket.close
        end
      rescue StandardError
        nil
      end

      yield FakeVnc.new(port, received, front)
    ensure
      front.close unless front.closed?
      thread&.join(1)
    end
  end
end
