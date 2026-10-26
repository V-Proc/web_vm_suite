# frozen_string_literal: true


require "test_helper"

module Vms
  class StartServiceTest < ActiveSupport::TestCase
    test "запускает домен и переводит статус в running" do
      vm = virtual_machines(:nginx_alpha)
      fake_domain = FakeDomain.new(uuid: vm.libvirt_uuid)

      with_fake_connection(FakeConnection.new(fake_domain)) do
        result = StartService.new(virtual_machine: vm).call

        assert result.success?
        assert_includes fake_domain.actions, :create
        assert_equal :running, vm.reload.status.to_sym
      end
    end

    test "возвращает failure, когда домен не найден в гипервизоре" do
      vm = virtual_machines(:nginx_alpha)
      conn = FakeConnection.new(nil) # lookup вернет nil

      with_fake_connection(conn) do
        result = StartService.new(virtual_machine: vm).call

        assert result.failure?
        assert_equal :created, vm.reload.status.to_sym
      end
    end

    test "ошибка libvirt доходит как failure без исключения" do
      vm = virtual_machines(:nginx_alpha)
      conn = Object.new
      def conn.call(*)
        App::Result.fail("libvirt: соединение потеряно")
      end

      with_fake_connection(conn) do
        result = StartService.new(virtual_machine: vm).call

        assert result.failure?
        assert_includes result.errors, "libvirt: соединение потеряно"
        assert_equal :created, vm.reload.status.to_sym
      end
    end
  end
end
