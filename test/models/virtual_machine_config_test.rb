# frozen_string_literal: true


require "test_helper"

class VirtualMachineConfigTest < ActiveSupport::TestCase
  test "проверяет позитивность ресурсов" do
    config = VirtualMachineConfig.new(workgroup: workgroups(:alpha), name: "x", cpu_cores: 0, ram_mb: -5, disk_gb: 0)
    assert_not config.valid?
    assert config.errors.key?(:cpu_cores)
    assert config.errors.key?(:ram_mb)
    assert config.errors.key?(:disk_gb)
  end

  test "имя уникально в пределах воркгруппы" do
    dup = VirtualMachineConfig.new(
      workgroup: workgroups(:alpha),
      name: virtual_machine_configs(:small).name,
      cpu_cores: 1, ram_mb: 512, disk_gb: 10
    )
    assert_not dup.valid?

    dup.workgroup = workgroups(:beta)
    assert dup.valid?
  end
end
