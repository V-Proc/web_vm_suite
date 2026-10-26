# frozen_string_literal: true


module Vms
  class CreateService
    def initialize(user:, params:)
      @user = user
      @params = params
      @vm = nil
    end

    def call
      return App::Result.fail("Пользователь не найден") if user.blank?
      return App::Result.fail("Пользователь не является участником воркгруппы") unless authorized?

      build_vm
      return App::Result.fail(*vm.errors.full_messages) unless vm.valid?

      xml = build_xml
      result = define_domain(xml)
      return result unless result.success?

      save_uuid(result.value)
    end

    attr_reader :user, :params, :vm

    private

    def authorized?
      workgroup = Workgroup.find_by(id: params[:workgroup_id])
      workgroup.present? && user.member_of?(workgroup)
    end

    def build_vm
      @vm = VirtualMachine.new(
        name: params[:name],
        workgroup_id: params[:workgroup_id],
        user: user,
        virtual_machine_config_id: params[:virtual_machine_config_id],
        status: :created
      )
    end

    def build_xml
      config = VirtualMachineConfig.find_by(id: params[:virtual_machine_config_id])
      Vms::DomainXmlBuilder.new(config: config).call
    end

    def define_domain(xml)
      Vms::Connection.new.call do |conn|
        domain = conn.define_domain_xml(xml)
        App::Result.ok(domain)
      end
    end

    def save_uuid(domain)
      vm.libvirt_uuid = domain.uuid
      vm.save!
      App::Result.ok(vm)
    end
  end
end
