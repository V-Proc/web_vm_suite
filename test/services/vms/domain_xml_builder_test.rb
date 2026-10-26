# frozen_string_literal: true


require "test_helper"

class DomainXmlBuilderTest < ActiveSupport::TestCase
  test "включает имя, RAM, vcpu и диск из конфигурации" do
    xml = Vms::DomainXmlBuilder.new(config: virtual_machine_configs(:small)).call

    assert_includes xml, "<name>small-box</name>"
    assert_includes xml, "<memory unit='MiB'>2048</memory>"
    assert_includes xml, "<vcpu>2</vcpu>"
    assert_includes xml, "20" # диск из конфига (qcow2 файл)
    assert_includes xml, "<driver name='qemu' type='qcow2'/>"
  end

  test "экранирует спецсимволы в имени" do
    config = VirtualMachineConfig.new(name: "<evil>&\"", cpu_cores: 1, ram_mb: 512, disk_gb: 10)
    xml = Vms::DomainXmlBuilder.new(config: config).call

    assert_includes xml, "<name>&lt;evil&gt;&amp;&quot;</name>"
    assert_not_includes xml, "<evil"
  end

  test "xml является валидным минимальным манифестом kvm" do
    xml = Vms::DomainXmlBuilder.new(config: virtual_machine_configs(:big)).call

    assert_includes xml, "<domain type='kvm'>"
    assert_includes xml, "<type arch='x86_64' machine='q35'>hvm</type>"
  end
end
