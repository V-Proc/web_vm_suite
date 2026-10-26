# frozen_string_literal: true


class Workgroup < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :virtual_machines, dependent: :destroy
  has_many :virtual_machine_configs, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { maximum: 64 }
end
