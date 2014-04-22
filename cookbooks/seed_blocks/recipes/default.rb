ey_cloud_report "seed_blocks" do
  message "Enabling access to SeedBlocks gem"
end

# Update SSH config.erb to force the server to use the correct deploy key when attempting to access the SeedBlocks gem
node[:applications].each do |app_name,data|
  template "/home/deploy/.ssh/config" do
    action :create
    source "config.erb"
    owner "root"
    group "root"
    mode 0644
    variables({
      :app_name => app_name
    })
  end
end

ey_cloud_report "seed_blocks" do
  message "Done granting access to SeedBlocks gem"
end