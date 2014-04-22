if node[:mongo_instances].length > 0
  user = node[:users].first
  mongo_app_names = node[:applications].keys

  mongo_app_names.each do |mongo_app_name|

    template "/data/#{mongo_app_name}/shared/config/mongodb.yml" do
      source "mongodb.yml.erb"
      owner user[:username]
      group user[:username]
      mode 0755

      hosts = node[:mongo_instances].map { |hostname| [ hostname, node[:mongo_port].to_i ] }
      variables(:yaml_file => { node[:environment][:framework_env] => { :hosts => hosts } })
    end

    #Mongoid.yml_v3
    template "/data/#{mongo_app_name}/shared/config/mongoid.yml" do
      source "mongoid_v2.yml.erb"
      owner user[:username]
      group user[:username]
      mode 0755

      hosts = node[:mongo_instances].map { |hostname| [hostname, node[:mongo_port].to_i] }
      # hosts = [[ "localhost", node[:mongo_port].to_i ]] if hosts.empty? # solo case
      replica_set = !!node[:mongo_replset]
      variables(
        :environment => node[:environment][:framework_env], 
        :hosts => hosts,
        :replica_set => replica_set,
        :mongo_replsetname => '%s_%s' % [mongo_app_name, node[:environment][:framework_env]]
      )
    end

  end
end
