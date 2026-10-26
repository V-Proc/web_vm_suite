# frozen_string_literal: true


require "test_helper"

module Vms
  class DestroyServiceTest < ActiveSupport::TestCase
    test "undefine домен и удаляет запись из БД" do
      vm = virtual_machines(:nginx_alpha)
      fake_domain = FakeDomain.new(uuid: vm.libvirt_uuid)

      with_fake_connection(FakeConnection.new(fake_domain)) do
        result = DestroyService.new(virtual_machine: vm).call

        assert result.success?
        assert_includes fake_domain.actions, :undefine
        assert_not VirtualMachine.exists?(vm.id)
      end
    end

    test "не удаляет запись, если домен не найден в гипервизоре" do
      vm = virtual_machines(:nginx_alpha)

      with_fake_connection(FakeConnection.new(nil)) do
        result = DestroyService.new(virtual_machine: vm).call

        assert result.failure?
        assert VirtualMachine.exists?(vm.id)
      end
    end
  end
end
