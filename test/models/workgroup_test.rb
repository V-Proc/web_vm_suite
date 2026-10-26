# frozen_string_literal: true


require "test_helper"

class WorkgroupTest < ActiveSupport::TestCase
  test "не проходит валидацию без имени" do
    wg = Workgroup.new
    assert_not wg.valid?
    assert wg.errors.added?(:name, :blank)
  end

  test "имя должно быть уникальным" do
    wg = Workgroup.new(name: workgroups(:alpha).name)
    assert_not wg.valid?
    assert wg.errors.added?(:name, :taken, value: wg.name)
  end

  test "имеяет связи на users / virtual_machines / virtual_machine_configs" do
    assert_respond_to workgroups(:alpha), :users
    assert_respond_to workgroups(:alpha), :virtual_machines
    assert_respond_to workgroups(:alpha), :virtual_machine_configs
  end
end
