# frozen_string_literal: true


require "test_helper"

module Vms
  class StopServiceTest < ActiveSupport::TestCase
    test "останавливает домен и переводит статус в stopped" do
      vm = virtual_machines(:nginx_alpha)
      fake_domain = FakeDomain.new(uuid: vm.libvirt_uuid)

      with_fake_connection(FakeConnection.new(fake_domain)) do
        result = StopService.new(virtual_machine: vm).call

        assert result.success?
        assert_includes fake_domain.actions, :shutdown
        assert_equal :stopped, vm.reload.status.to_sym
      end
    end

    test "возвращает failure, когда домен не найден" do
      vm = virtual_machines(:nginx_alpha)

      with_fake_connection(FakeConnection.new(nil)) do
        result = StopService.new(virtual_machine: vm).call

        assert result.failure?
        assert_equal :created, vm.reload.status.to_sym
      end
    end
  end
end
