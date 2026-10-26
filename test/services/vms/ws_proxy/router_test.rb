# frozen_string_literal: true

require "test_helper"

module Vms
  class WsProxyRouterTest < ActiveSupport::TestCase
    test "токен-uuid превращается в host/port дисплея" do
      vm = virtual_machines(:nginx_alpha)
      domain = FakeDomain.new(uuid: vm.libvirt_uuid, graphics_port: 5912)

      with_fake_connection(FakeConnection.new(domain)) do
        target = Vms::WsProxy::Router.new.target_for(vm.libvirt_uuid)

        assert target
        assert_equal 5912, target[:port]
        assert_equal vm, target[:vm]
      end
    end

    test "неизвестный токен -> nil" do
      assert_nil Vms::WsProxy::Router.new.target_for("00000000-dead-beef-0000-000000000000")
    end

    test "пустой токен -> nil без обращения к БД" do
      assert_nil Vms::WsProxy::Router.new.target_for("")
      assert_nil Vms::WsProxy::Router.new.target_for(nil)
    end

    test "ошибка libvirt -> nil без исключения" do
      vm = virtual_machines(:nginx_alpha)
      conn = Object.new
      def conn.call(*)
        App::Result.fail("libvirt: соединение потеряно")
      end

      with_fake_connection(conn) do
        assert_nil Vms::WsProxy::Router.new.target_for(vm.libvirt_uuid)
      end
    end
  end
end
