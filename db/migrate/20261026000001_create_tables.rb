# frozen_string_literal: true


class CreateTables < ActiveRecord::Migration[7.1]
  def change
    create_table :workgroups do |t|
      t.string :name, limit: 64, null: false
      t.text :description
      t.timestamps
    end
    add_index :workgroups, :name, unique: true

    create_table :users do |t|
      t.references :workgroup, null: false, foreign_key: true
      t.string :login, limit: 64, null: false
      t.string :display_name, limit: 128
      t.string :role, limit: 16, null: false, default: "member"
      t.timestamps
    end
    add_index :users, :login, unique: true

    create_table :virtual_machine_configs do |t|
      t.references :workgroup, null: false, foreign_key: true
      t.string :name, limit: 64, null: false
      t.integer :cpu_cores, null: false
      t.integer :ram_mb, null: false
      t.integer :disk_gb, null: false
      t.timestamps
    end
    add_index :virtual_machine_configs, %i[workgroup_id name], unique: true

    create_table :virtual_machines do |t|
      t.references :workgroup, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :virtual_machine_config, null: false, foreign_key: true
      t.string :name, limit: 64, null: false
      t.string :libvirt_uuid, limit: 64
      t.integer :status, null: false, default: 0
      t.timestamps
    end
    add_index :virtual_machines, :name, unique: true
    add_index :virtual_machines, :libvirt_uuid, unique: true
  end
end
