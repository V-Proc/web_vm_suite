# frozen_string_literal: true

module Vms
  module WsProxy
    # Сопоставляет токен (libvirt_uuid из URL) с TCP-адресом VNC-дисплея
    # соответствующего домена. Сегодня через один Libvirt::Connection,
    # завтра у машины свой - здесь это не важно.
    class Router
      def target_for(token)
        return nil if token.blank?

        vm = VirtualMachine.find_by(libvirt_uuid: token)
        return nil unless vm

        result = lookup_graphics(vm)
        return nil unless result.success?

        graphics = result.value
        { host: graphics[:listen], port: graphics[:port], vm: vm }
      end

      private

      def lookup_graphics(vm)
        Vms::Connection.new.call(uuid: vm.libvirt_uuid) do |_conn, domain|
          return App::Result.fail("Домен не найден в гипервизоре") if domain.nil?

          info = domain.graphics_address || {}
          App::Result.ok(
            listen: info[:listen] || ENV.fetch("LIBVIRT_HOST", "127.0.0.1"),
            port: info[:port]
          )
        end
      end
    end
  end
end
