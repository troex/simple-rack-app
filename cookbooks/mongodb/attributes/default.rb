default[:mongo_version] = "2.4.6"
default[:mongo_path] = "/usr"
default[:mongo_base] = "/data/mongodb"
default[:mongo_port] = "27017"
default[:mongo_host] = node[:ec2][:local_hostname]
default[:total_memory_mb] = `df -m /data | awk '/dev/ {print $2}'`.to_i
default[:oplog_memory_percentage] = "0.1"
default[:oplog_size] = (default[:total_memory_mb] * default[:oplog_memory_percentage].to_f).to_i
default[:mongo_master] = false
default[:mongo_arbiter] = false

Chef::Log.info 'Internal hostname: %s' % default[:mongo_host]

mongo_instances = node[:engineyard][:environment][:instances].select do |instance|
  ['db_master', 'db_slave', 'solo'].include?(instance[:role])
end
default[:mongo_instances] = mongo_instances.map { |instance| instance[:private_hostname] }

if default[:mongo_instances].length == 2
  mongo_arbiter = nil
  ['util', 'app', 'app_master'].each do |role|
    mongo_arbiter ||= node[:engineyard][:environment][:instances].select { |instance| instance[:role] == role }.first
  end
  if mongo_arbiter
    default[:mongo_arbiter] = mongo_arbiter[:private_hostname]
    default[:mongo_instances] << default[:mongo_arbiter]
    Chef::Log.info 'MongoDB arbiter: %s' % default[:mongo_arbiter]
  end
end

if default[:mongo_instances].length >= 2
  default[:mongo_replset] = node[:environment][:name]
  mongo_master = node[:engineyard][:environment][:instances].select { |instance| instance[:role] == 'db_master' }.first
  default[:mongo_master] = mongo_master[:private_hostname] if mongo_master
  Chef::Log.info 'MongoDB master: %s' % default[:mongo_master]
  Chef::Log.info 'MongoDB replication set: %s' % default[:mongo_replset]
else
  default[:mongo_replset] = false
end

Chef::Log.info 'MongoDB instances: %s' % default[:mongo_instances].join(', ')
