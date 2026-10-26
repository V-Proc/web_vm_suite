# frozen_string_literal: true

module Vms
  class ConsoleService
    def initialize(virtual_machine:)
      @virtual_machine = virtual_machine
    end

    def call
      return App::Result.fail("Домен не определен в гипервизоре") if @virtual_machine.libvirt_uuid.blank?

      result = lookup_graphics
      return result unless result.success?

      graphics = result.value
      App::Result.ok(
        vm_id: @virtual_machine.id,
        vm_name: @virtual_machine.name,
        ws_url: ws_url(graphics),
        kind: graphics.fetch(:kind, "vnc")
      )
    end

    private

    def lookup_graphics
      Vms::Connection.new.call(uuid: @virtual_machine.libvirt_uuid) do |_conn, domain|
        return App::Result.fail("Домен не найден в гипервизоре") if domain.nil?

        App::Result.ok(graphics_of(domain))
      end
    end

    def graphics_of(domain)
      info = domain.graphics_address || {}
      {
        kind: info[:type] || "vnc",
        listen: info[:listen] || server_listen,
        port: info[:port]
      }
    end

    def server_listen
      ENV.fetch("LIBVIRT_HOST", "127.0.0.1")
    end

    def ws_url(graphics)
      prefix = ENV.fetch("NOVNC_PROXY_URL", "wss://localhost:3036/websockify")
      "#{prefix}?host=#{graphics[:listen]}&port=#{graphics[:port]}&token=#{@virtual_machine.libvirt_uuid}"
    end
  end
end
