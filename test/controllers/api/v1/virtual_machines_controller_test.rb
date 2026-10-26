# frozen_string_literal: true


require "test_helper"

module Api
  module V1
    class VirtualMachinesControllerTest < ActionDispatch::IntegrationTest
      test "GET /api/v1/virtual_machines возвращает список" do
        get api_v1_virtual_machines_path
        assert_response :success
        body = JSON.parse(response.body)
        assert_includes body["data"].map { |d| d["name"] }, "nginx-alpha"
      end

      test "POST /api/v1/virtual_machines без прав возвращает errors" do
        post api_v1_virtual_machines_path,
             params: { virtual_machine: { name: "x-vm", workgroup_id: workgroups(:beta).id,
                                          virtual_machine_config_id: virtual_machine_configs(:small).id } },
             as: :json
        assert_response :unprocessable_entity
        assert JSON.parse(response.body)["errors"].present?
      end

      test "POST /api/v1/virtual_machines/:id/start возвращает vm со статусом running" do
        vm = virtual_machines(:nginx_alpha)
        fake_domain = FakeDomain.new(uuid: vm.libvirt_uuid)
        with_fake_connection(FakeConnection.new(fake_domain)) do
          post start_api_v1_virtual_machine_path(vm), as: :json
          assert_response :success
          assert_equal "running", JSON.parse(response.body).dig("data", "status")
        end
      end

      test "POST /api/v1/virtual_machines/:id/stop возвращает vm со статусом stopped" do
        vm = virtual_machines(:nginx_alpha)
        fake_domain = FakeDomain.new(uuid: vm.libvirt_uuid)
        with_fake_connection(FakeConnection.new(fake_domain)) do
          post stop_api_v1_virtual_machine_path(vm), as: :json
          assert_response :success
          assert_equal "stopped", JSON.parse(response.body).dig("data", "status")
        end
      end

      test "GET /console возвращает ws-url прокси" do
        vm = virtual_machines(:nginx_alpha)
        domain = FakeDomain.new(uuid: vm.libvirt_uuid, graphics_port: 5909)

        with_fake_connection(FakeConnection.new(domain)) do
          get console_api_v1_virtual_machine_path(vm), as: :json
          assert_response :success
          data = JSON.parse(response.body).fetch("data")
          assert_equal "vnc", data["kind"]
          assert_includes data["ws_url"], "port=5909"
          assert_includes data["ws_url"], vm.libvirt_uuid
        end
      end

      test "DELETE удаляет VM при наличии домена" do
        vm = virtual_machines(:nginx_alpha)
        fake_domain = FakeDomain.new(uuid: vm.libvirt_uuid)
        with_fake_connection(FakeConnection.new(fake_domain)) do
          delete api_v1_virtual_machine_path(vm), as: :json
          assert_response :success
          assert_not VirtualMachine.exists?(vm.id)
        end
      end
    end
  end
end
