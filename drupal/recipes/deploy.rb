include_recipe "cron"
include_recipe 'deploy'


node[:deploy].each do |application, deploy|

   include_recipe 'apache2::service'
   if deploy[:application_type] != 'php'
     Chef::Log.debug("Skipping deploy::php application #{application} as it is not an PHP app")
     next
   end

   bash "change_owner" do
     code <<-EOH
        chown -R #{deploy[:user]}:#{deploy[:group]} #{node[:drupal][:ebs][:mount_point]}
     EOH
   end

  template "#{deploy[:absolute_document_root]}sites/default/settings.php" do
    source "settings.php.erb"
    owner deploy[:user]
    group deploy[:group]
    mode "0644"
    action :create
  end

  template "/etc/php5/apache2/php.ini" do
    source "php.ini.erb"
    mode "0644"
    action :create
    notifies :restart, "service[apache2]"
  end
 
  cron "drupal_cron" do
    command "cd #{deploy[:absolute_document_root]}; drush cron"
    minute "*/15"
  end

   link "#{deploy[:absolute_document_root]}sites/default/files" do
     owner deploy[:user]
     group deploy[:group]
     to node[:drupal][:ebs][:mount_point]
     not_if { File.exist?("{deploy[:absolute_document_root]}sites/default/files") }
   end	

  bash "update_db" do
    user deploy[:user]
    cwd "#{deploy[:absolute_document_root]}"
    code <<-EOH
    drush updatedb
    EOH
  end

  bash "update_db" do
    user deploy[:user]
    cwd "#{deploy[:absolute_document_root]}"
    code <<-EOH
    drush cc
    EOH
  end
end




