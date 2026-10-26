# frozen_string_literal: true


ActiveRecord::Schema[7.1].define(version: 2026_10_26_000001) do
  create_table "users", force: :cascade do |t|
    t.integer "workgroup_id", null: false
    t.string "login", limit: 64, null: false
    t.string "display_name", limit: 128
    t.string "role", limit: 16, default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["login"], name: "index_users_on_login", unique: true
    t.index ["workgroup_id"], name: "index_users_on_workgroup_id"
  end

  create_table "virtual_machine_configs", force: :cascade do |t|
    t.integer "workgroup_id", null: false
    t.string "name", limit: 64, null: false
    t.integer "cpu_cores", null: false
    t.integer "ram_mb", null: false
    t.integer "disk_gb", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["workgroup_id", "name"], name: "index_virtual_machine_configs_on_workgroup_id_and_name", unique: true
    t.index ["workgroup_id"], name: "index_virtual_machine_configs_on_workgroup_id"
  end

  create_table "virtual_machines", force: :cascade do |t|
    t.integer "workgroup_id", null: false
    t.integer "user_id", null: false
    t.integer "virtual_machine_config_id", null: false
    t.string "name", limit: 64, null: false
    t.string "libvirt_uuid", limit: 64
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["libvirt_uuid"], name: "index_virtual_machines_on_libvirt_uuid", unique: true
    t.index ["name"], name: "index_virtual_machines_on_name", unique: true
    t.index ["user_id"], name: "index_virtual_machines_on_user_id"
    t.index ["virtual_machine_config_id"], name: "index_virtual_machines_on_virtual_machine_config_id"
    t.index ["workgroup_id"], name: "index_virtual_machines_on_workgroup_id"
  end

  create_table "workgroups", force: :cascade do |t|
    t.string "name", limit: 64, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_workgroups_on_name", unique: true
  end

  add_foreign_key "users", "workgroups"
  add_foreign_key "virtual_machine_configs", "workgroups"
  add_foreign_key "virtual_machines", "users"
  add_foreign_key "virtual_machines", "virtual_machine_configs"
  add_foreign_key "virtual_machines", "workgroups"
end
