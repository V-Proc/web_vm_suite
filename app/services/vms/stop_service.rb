# frozen_string_literal: true


module Vms
  class StopService
    def initialize(virtual_machine:)
      @virtual_machine = virtual_machine
    end

    def call
      result = perform_libvirt_action(:shutdown)
      if result.success?
        @virtual_machine.update(status: :stopped)
        App::Result.ok(@virtual_machine)
      else
        result
      end
    end

    private

    def perform_libvirt_action(method)
      Vms::Connection.new.call(uuid: @virtual_machine.libvirt_uuid) do |_conn, domain|
        return App::Result.fail("Домен не найден в гипервизоре") if domain.nil?

        domain.public_send(method)
        App::Result.ok(domain)
      end
    end
  end
end
