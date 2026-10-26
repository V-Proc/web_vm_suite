# frozen_string_literal: true


class User < ApplicationRecord
  belongs_to :workgroup
  has_many :virtual_machines, dependent: :destroy

  ROLES = %w[admin member].freeze

  validates :login, presence: true, uniqueness: true, length: { maximum: 64 }
  validates :role, inclusion: { in: ROLES }

  def member_of?(workgroup)
    self.workgroup == workgroup
  end

  def admin?
    role == "admin"
  end
end
