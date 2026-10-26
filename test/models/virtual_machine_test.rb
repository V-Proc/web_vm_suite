# frozen_string_literal: true


require "test_helper"

class VirtualMachineTest < ActiveSupport::TestCase
  test "статусы определены и дефолтный — created" do
    assert_equal 0, VirtualMachine::STATUSES[:created]
    assert virtual_machines(:nginx_alpha).created?
    assert_equal(:created, virtual_machines(:nginx_alpha).status.to_sym)
  end

  test "имя уникально" do
    vm = VirtualMachine.new(
      workgroup: workgroups(:alpha),
      user: users(:alice),
      virtual_machine_config: virtual_machine_configs(:small),
      name: virtual_machines(:nginx_alpha).name,
      status: :created
    )
    assert_not vm.valid?
  end

  test "summary возвращает полную структуру для фронтенда" do
    summary = virtual_machines(:nginx_alpha).summary

    assert_equal "nginx-alpha", summary[:name]
    assert_equal "alice", summary[:owner][:login]
    assert_equal "alpha-team", summary[:workgroup][:name]
    assert_equal "small-box", summary[:config][:name]
    assert_equal 2048, summary[:config][:ram_mb]
  end
end
