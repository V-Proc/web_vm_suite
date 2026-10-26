# frozen_string_literal: true


module Vms
  class DestroyService
    def initialize(virtual_machine:)
      @virtual_machine = virtual_machine
    end

    def call
      result = perform_libvirt_action
      return result unless result.success?

      @virtual_machine.destroy
      App::Result.ok(@virtual_machine)
    end

    private

    def perform_libvirt_action
      Vms::Connection.new.call(uuid: @virtual_machine.libvirt_uuid) do |_conn, domain|
        return App::Result.fail("Домен не найден в гипервизоре") if domain.nil?

        domain.undefine
        App::Result.ok(domain)
      end
    end
  end
end
