# frozen_string_literal: true


require "test_helper"

module Vms
  class CreateServiceTest < ActiveSupport::TestCase
    test "создает VM и сохраняет uuid, когда пользователь участник группы" do
      user = users(:alice)
      fake_domain = FakeDomain.new(uuid: "deadbeef-0000-0000-0000-111111111111")
      conn = FakeConnection.new(fake_domain, domain_factory: -> { fake_domain })

      with_fake_connection(conn) do
        result = CreateService.new(user: user, params: create_params).call
        assert result.success?
        vm = result.value
        assert_equal "test-vm", vm.name
        assert_equal fake_domain.uuid, vm.libvirt_uuid
        assert_equal(:created, vm.status.to_sym)
      end
    end

    test "запрещает создание VM для пользователя чужой воркгруппы" do
      outsider = users(:bob) # из другой воркгруппы
      stub_no_libvirt do
        result = CreateService.new(user: outsider, params: create_params).call

        assert result.failure?
        assert_includes result.errors.join(" "), "воркгруппы"
        assert_not VirtualMachine.exists?(name: "test-vm")
      end
    end

    test "возвращает ошибку валидации для некорректного имени" do
      user = users(:alice)
      stub_no_libvirt do
        result = CreateService.new(user: user, params: create_params(name: nil)).call

        assert result.failure?
        assert_not VirtualMachine.exists?(name: nil)
      end
    end

    test "не оставляет запись в БД при провале define в гипервизоре" do
      user = users(:alice)
      conn = Object.new
      def conn.call(*)
        App::Result.fail("libvirt: гипервизор недоступен")
      end

      with_fake_connection(conn) do
        result = CreateService.new(user: user, params: create_params).call

        assert result.failure?
        assert_not VirtualMachine.exists?(name: "test-vm")
      end
    end

    private

    def create_params(name: "test-vm")
      {
        name: name,
        workgroup_id: users(:alice).workgroup_id,
        virtual_machine_config_id: virtual_machine_configs(:small).id
      }
    end

    def stub_no_libvirt
      conn = Object.new
      def conn.call(*)
        raise "libvirt не должен вызываться в тесте"
      end
      with_fake_connection(conn) { yield }
    end
  end
end
