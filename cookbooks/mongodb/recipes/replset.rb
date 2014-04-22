user = node[:users].first

if node[:mongo_replset]
  Chef::Log.info "Setting up Replica set: #{node[:mongo_replset]} \n mongo_nodes: #{node[:mongo_instances].inspect}"
  if node[:mongo_host] == node[:mongo_master]
    # setup_js = "#{node[:mongo_base]}/setup_replset.js"
    setup_js = "/db/mongodb/setup_replset.js"

    template setup_js do
      source "setup_replset.js.erb"
      owner user[:username]
      group user[:username]
      mode '0755'
      variables({
        :mongo_replset  => node[:mongo_replset],
        :mongo_nodes    => node[:mongo_instances].reject { |instance| instance == node[:mongo_arbiter] },
        :mongo_port     => node[:mongo_port],
        :mongo_arbiter  => node[:mongo_arbiter]
      })
    end

    #----- wait for set members to be up and initialize -----
    node[:mongo_instances].each do |mongo_node|
      execute "wait for mongo on #{mongo_node} to come up" do
        command "until echo 'exit' | #{node[:mongo_path]}/bin/mongo #{mongo_node}:#{node[:mongo_port]}/local --quiet; do sleep 10s; done"
      end
    end

    # ----- configure the set
    execute "setup replset #{node[:mongo_replset]}" do
      command "#{node[:mongo_path]}/bin/mongo local #{setup_js}"
      only_if "echo 'rs.status()' | #{node[:mongo_path]}/bin/mongo local --quiet | grep -q 'run rs.initiate'"
      Chef::Log.info "Replica set node initialized" 
    end
  else
    Chef::Log.info "Not first node in replica or not enough set members defined, skipping set configuration"
  end
end
