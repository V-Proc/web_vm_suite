# frozen_string_literal: true


module Vms
  require "cgi"

  class DomainXmlBuilder
    def initialize(config:)
      @config = config
    end

    def call
      <<~XML
        <domain type='kvm'>
          <name>#{escape(name)}</name>
          <memory unit='MiB'>#{config.ram_mb}</memory>
          <vcpu>#{config.cpu_cores}</vcpu>
          <os>
            <type arch='x86_64' machine='q35'>hvm</type>
          </os>
          <devices>
            <disk type='file' device='disk'>
              <source file='/var/lib/libvirt/images/#{escape(name)}.qcow2'/>
              <target dev='vda' bus='virtio'/>
              <driver name='qemu' type='qcow2'/>
            </disk>
            <interface type='network'>
              <source network='default'/>
              <model type='virtio'/>
            </interface>
            <graphics type='vnc' port='-1' autoport='yes'/>
          </devices>
        </domain>
      XML
    end

    private

    attr_reader :config

    def name
      config.name
    end

    def escape(str)
      CGI.escapeHTML(str.to_s)
    end
  end
end
