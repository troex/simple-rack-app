# Add your required timezone name here:
timezone = "US/Pacific"


service "vixie-cron"
service "sysklogd"
service "nginx"

link "/etc/localtime" do
  to "/usr/share/zoneinfo/#{timezone}"
  notifies :restart, resources(:service => ["vixie-cron", "sysklogd", "nginx"]), :delayed
  not_if "readlink /etc/localtime | grep -q '#{timezone}$'"
end
