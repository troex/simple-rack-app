#
# Cookbook Name:: mongodb
# Recipe:: default
#
# Save credentials on app_master
if ['app_master', 'app', 'solo', 'util'].include?(node[:instance_role])
  Chef::Log.info "creating app mongo.yml code"
  include_recipe "mongodb::app"
end

case node[:kernel][:machine]
when "i686"
  # Do nothing, you should never run MongoDB in a i686/i386 environment it will damage your data.
  Chef::Log.info "MongoDB cannot be hold data in 32bit systems"
else
  if node[:mongo_instances].include?(node[:mongo_host])

    ey_cloud_report "mongodb" do
      message "configuring mongodb"
    end

    include_recipe "mongodb::install"
    include_recipe "mongodb::configure"
    include_recipe "mongodb::backup"
    include_recipe "mongodb::start"

    if node[:mongo_replset]
      include_recipe "mongodb::replset"
    end
  end
end

#install mms on db_master or solo. This will need to change for db-less environments
if ['db_master', 'solo'].include?(node[:instance_role])
  Chef::Log.info "Installing MMS on #{node[:instance_role]}"
  include_recipe "mongodb::install_mms"
end
