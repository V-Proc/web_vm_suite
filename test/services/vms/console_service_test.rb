# frozen_string_literal: true

require "test_helper"

module Vms
  class ConsoleServiceTest < ActiveSupport::TestCase
    test "возвращает параметры vnc-дисплея и ws-url прокси" do
      vm = virtual_machines(:nginx_alpha)
      domain = FakeDomain.new(uuid: vm.libvirt_uuid, graphics_port: 5907)

      with_fake_connection(FakeConnection.new(domain)) do
        result = ConsoleService.new(virtual_machine: vm).call

        assert result.success?
        assert_includes result.value[:ws_url], "port=5907"
        assert_equal("vnc", result.value[:kind])
        assert_includes result.value[:ws_url], vm.libvirt_uuid
      end
    end

    test "failure, если домена нет в гипервизоре" do
      vm = virtual_machines(:nginx_alpha)

      with_fake_connection(FakeConnection.new(nil)) do
        result = ConsoleService.new(virtual_machine: vm).call

        assert result.failure?
        assert_includes result.errors.join(" "), "не найден"
      end
    end

    test "failure, если у VM нет uuid" do
      vm = VirtualMachine.new(virtual_machines(:nginx_alpha).attributes.merge("libvirt_uuid" => nil))

      result = ConsoleService.new(virtual_machine: vm).call

      assert result.failure?
    end
  end
end
