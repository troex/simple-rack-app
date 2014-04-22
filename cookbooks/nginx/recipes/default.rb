#
# Cookbook Name:: nginx
# Recipe:: default
#

if node[:instance_role] == "solo"

  custom_conf = ["/etc/nginx/http-custom.conf", "/etc/nginx/ssl/hdb_mtb.pem", "/etc/nginx/ssl/hdb_mtb.key"]
  custom_conf.each do |dest_file|
    src_file = dest_file.split("/").last
    remote_file dest_file do
      owner "deploy"
      group "deploy"
      mode 0644
      source src_file
      backup false
      action :create
    end
  end

  execute "/etc/init.d/nginx restart" do
    action :run
    epic_fail true
  end

  ey_cloud_report "nginx" do
    message "Nginx custom ssl proxy for solo instance"
  end

end
