# frozen_string_literal: true


class VirtualMachine < ApplicationRecord
  belongs_to :workgroup
  belongs_to :user
  belongs_to :virtual_machine_config

  STATUSES = {
    created: 0,
    running: 1,
    stopped: 2
  }.freeze

  enum status: STATUSES

  validates :name, presence: true, uniqueness: true, length: { maximum: 64 }

  def summary
    {
      id: id,
      name: name,
      uuid: libvirt_uuid,
      status: status,
      owner: { id: user_id, login: user.login },
      workgroup: { id: workgroup_id, name: workgroup.name },
      config: {
        id: virtual_machine_config_id,
        name: virtual_machine_config.name,
        cpu_cores: virtual_machine_config.cpu_cores,
        ram_mb: virtual_machine_config.ram_mb,
        disk_gb: virtual_machine_config.disk_gb
      },
      created_at: created_at,
      updated_at: updated_at
    }
  end
end
