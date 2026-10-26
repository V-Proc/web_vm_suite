# frozen_string_literal: true


wg = Workgroup.find_or_create_by!(name: "default") do |w|
  w.description = "Демо-воркгруппа"
end
admin = User.find_or_create_by!(login: "admin") do |u|
  u.workgroup = wg
  u.role = "admin"
end

VirtualMachineConfig.find_or_create_by!(workgroup: wg, name: "small-box") do |c|
  c.cpu_cores = 2
  c.ram_mb = 2048
  c.disk_gb = 20
end
VirtualMachineConfig.find_or_create_by!(workgroup: wg, name: "big-box") do |c|
  c.cpu_cores = 8
  c.ram_mb = 16_384
  c.disk_gb = 500
end

puts "Seeded workgroup=#{wg.name}, admin=#{admin.login}"
