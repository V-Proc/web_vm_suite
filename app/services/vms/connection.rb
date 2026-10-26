# frozen_string_literal: true


module Vms
  class Connection
    def initialize(uri: ENV.fetch("LIBVIRT_URI", "qemu:///system"))
      @uri = uri
    end

    def call(uuid: nil)
      domain = nil
      open do |conn|
        domain = uuid ? conn.lookup_domain_by_uuid(uuid) : nil
        return yield conn, domain
      end
    rescue StandardError => e
      Rails.logger.error("[Vms::Connection] #{e.class}: #{e.message}")
      App::Result.fail("libvirt: #{e.message}")
    end

    private

    def open
      require "libvirt" unless defined?(::Libvirt)
      conn = ::Libvirt.open(@uri)
      yield conn
    ensure
      conn&.close
    end
  end
end
