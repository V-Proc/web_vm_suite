# frozen_string_literal: true


class VirtualMachineConfig < ApplicationRecord
  belongs_to :workgroup
  has_many :virtual_machines, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: { scope: :workgroup_id },
                   length: { maximum: 64 }
  validates :cpu_cores, :ram_mb, :disk_gb,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 }
end
