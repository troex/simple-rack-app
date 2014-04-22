user = node[:users].first
mongodb_bin = "#{node[:mongo_path]}/bin"

mongo_base = if ['db_master', 'db_slave'].include?(node[:instance_role])
  '/db/mongodb' # save under /db on database instances
elsif node[:mongo_host] == node[:mongo_arbiter]
  '/mnt/mongodb' # under /mnt because it's an arbiter. No data saved
else
  node[:mongo_base] # default solo/util
end

mongo_data = mongo_base + '/data'
mongo_log  = mongo_base + '/log'

directory mongo_data do
  owner user[:username]
  group user[:username]
  mode  '0755'
  action :create
  recursive true
end

directory mongo_log do
  owner user[:username]
  group user[:username]
  mode '0755'
  action :create
  recursive true
end

directory '/var/run/mongodb' do
  owner user[:username]
  group user[:username]
  mode '0755'
  action :create
  recursive true
end

remote_file "/etc/init.d/mongodb" do
  source "mongodb.init"
  owner "root"
  group "root"
  mode 0755
  backup false
  action :create
end

remote_file "/etc/logrotate.d/mongodb" do
  owner "root"
  group "root"
  mode 0755
  source "mongodb.logrotate"
  backup false
  action :create
end

mongodb_options = { :exec => "#{mongodb_bin}/mongod",
                    :data_path => mongo_data,
                    :log_path => mongo_log,
                    :user => user[:username],
                    :pid_path => "/var/run/mongodb",
                    :ip => "0.0.0.0",
                    :port => node[:mongo_port],
                    :extra_opts => '' }

if node[:mongo_journaling]
  mongodb_options[:extra_opts]  << " --journal"
end

if node[:mongo_replset]
  mongodb_options[:extra_opts]  << " --replSet #{node[:mongo_replset]}"
end

if node[:oplog_size]
  mongodb_options[:extra_opts]  << " --oplogSize=#{node[:oplog_size]}"
end

mongodb_options[:extra_opts]  << " --directoryperdb"

# Chef::Log.info "Node extra_opts #{mongodb_options[:extra_opts]}"

template "/etc/conf.d/mongodb" do
  source "mongodb.conf.erb"
  owner "root"
  group "root"
  mode 0755
  variables({
    :mongodb_options => mongodb_options
  })
end

execute "enable-mongodb" do
  command "rc-update add mongodb default"
  action :run
end

execute "/etc/init.d/mongodb restart" do
  command "/etc/init.d/mongodb restart"
  action :run
end

