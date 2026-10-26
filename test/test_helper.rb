# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    class FakeDomain
      attr_reader :uuid, :actions

      def initialize(uuid: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee", graphics_port: 5900)
        @uuid = uuid
        @graphics_port = graphics_port
        @graphics_listen = nil
        @graphics_type = "vnc"
        @actions = []
      end

      def define_domain_xml(_xml)
        actions << :define_domain_xml
        self
      end

      def create
        actions << :create
      end

      def shutdown
        actions << :shutdown
      end

      def undefine
        actions << :undefine
      end

      def graphics_address
        @graphics ||= { type: @graphics_type || "vnc",
                        listen: @graphics_listen || "0.0.0.0",
                        port: @graphics_port || port }.compact
      end
    end

    require "test_helper"

class FakeConnection
      def self.for(uuid: nil, domain_uuid: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")
        domain = uuid.nil? ? nil : FakeDomain.new(uuid: domain_uuid)
        new(domain)
      end

      def initialize(domain, domain_factory: -> { FakeDomain.new })
        @domain = domain
        @domain_factory = domain_factory
      end

      def call(uuid: nil)
        domain = uuid ? @domain : nil
        fake_conn = Object.new
        factory = @domain_factory
        fake_conn.define_singleton_method(:define_domain_xml) { |_xml| factory.call }
        yield fake_conn, domain
      end
    end

    def with_fake_connection(connection)
      original = Vms::Connection.method(:new)
      Vms::Connection.singleton_class.define_method(:new) { connection }
      yield
    ensure
      Vms::Connection.singleton_class.remove_method(:new) rescue nil
      Vms::Connection.define_singleton_method(:new) { |*a, **k| original.call(*a, **k) }
    end
  end
end
