# frozen_string_literal: true


module Api
  module V1
    class VirtualMachinesController < ApplicationController
      before_action :set_virtual_machine, only: %i[show start stop destroy console]

      def index
        render json: { data: scoped_vms.map(&:summary) }
      end

      def show
        render json: { data: @virtual_machine.summary }
      end

      def create
        result = Vms::CreateService.new(user: current_user, params: vm_params).call

        if result.success?
          render json: { data: result.value.summary }, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_content
        end
      end

      def start
        run_action Vms::StartService
      end

      def stop
        run_action Vms::StopService
      end

      def console
        result = Vms::ConsoleService.new(virtual_machine: @virtual_machine).call

        if result.success?
          render json: { data: result.value }
        else
          render json: { errors: result.errors }, status: :unprocessable_content
        end
      end

      def destroy
        run_action Vms::DestroyService
      end

      private

      def run_action(service_class)
        result = service_class.new(virtual_machine: @virtual_machine).call

        if result.success?
          render json: { data: result.value.summary }
        else
          render json: { errors: result.errors }, status: :unprocessable_content
        end
      end

      def set_virtual_machine
        @virtual_machine = scoped_vms.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { errors: ["Виртуальная машина не найдена"] }, status: :not_found
      end

      def current_user
        User.first
      end

      def scoped_vms
        VirtualMachine.where(workgroup_id: current_user.workgroup_id)
      end

      def vm_params
        params.require(:virtual_machine).permit(
          :name, :workgroup_id, :virtual_machine_config_id
        )
      end
    end
  end
end
