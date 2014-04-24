## Cookbook Name:: drupal-solr
## Recipe:: install_solr
##


# Extract war file from solr archive
ark "solr-#{node['drupal-solr']['solr_version']}" do
  url node['drupal-solr']['url']
  action :put
  owner node['drupal-solr']['tomcat_user']
end

bash "copy_source" do
    code <<-EOH
    cp -r /usr/local/solr-#{node['drupal-solr']['solr_version']}/dist/solrj-lib/* #{node['drupal-solr']['tomcat_lib_dir']}
    EOH
end


remote_file "#{node['drupal-solr']['tomcat_conf_dir']}/log4j.properties" do 
  source "file:///usr/local/solr-#{node['drupal-solr']['solr_version']}/example/resources/log4j.properties"
  owner node['drupal-solr']['tomcat_user']
  group node['drupal-solr']['tomcat_group']
  mode 0755
end

remote_file "#{node['drupal-solr']['tomcat_webapp_dir']}/solr.war" do 
  source "file:///usr/local/solr-#{node['drupal-solr']['solr_version']}/dist/solr-#{node['drupal-solr']['solr_version']}.war "
  owner node['drupal-solr']['tomcat_user']
  group node['drupal-solr']['tomcat_group']
  mode 0755
end

directory node['drupal-solr']['solr_home'] do
  owner node['drupal-solr']['tomcat_user']
  group node['drupal-solr']['tomcat_group']
  mode 0755
  recursive true
end

remote_directory node['drupal-solr']['tomcat_lib_dir']  do
  files_mode "755"
  files_group node['drupal-solr']['tomcat_group']	
  files_owner node['drupal-solr']['tomcat_user']
  mode "755"
  owner node['drupal-solr']['tomcat_user']
  source "file:///usr/local/solr-#{node['drupal-solr']['solr_version']}/example/solr/collection1/conf"
  group node['drupal-solr']['tomcat_group']
end


template "#{node['drupal-solr']['tomcat_conf_dir']}/Catalina/localhost/solr_context.xml}" do
  owner node['drupal-solr']['tomcat_user']
  group node['drupal-solr']['tomcat_group']
  source "solr_context.xml.erb"
end

directory "#{node['drupal-solr']['solr_home']}/drupal}" do
  owner node['drupal-solr']['tomcat_user']
  group node['drupal-solr']['tomcat_group']
  mode 0755
  recursive true
end

remote_directory "#{node['drupal-solr']['solr_home']}/drupal}"  do
  files_mode "755"
  files_group node['drupal-solr']['tomcat_group']	
  files_owner node['drupal-solr']['tomcat_user']
  mode "755"
  owner node['drupal-solr']['tomcat_user']
  source "file://#{node['drupal-solr']['solr_home']}/conf"
  group node['drupal-solr']['tomcat_group']
end

[ 
   'elevate.xml',
   'mapping-ISOLatin1Accent.txt',
   'protwords.txt',
   'schema.xml',
   'schema_extra_fields.xml',
   'schema_extra_types.xml',
   'solrconfig.xml',
   'solrconfig_extra.xml',
   'solrcore.properties',
   'stopwords.txt',
   'synonyms.txt',
].each do |script|
  cookbook_file "#{node['drupal-solr']['solr_home']}/conf/#{script}" do
    source "#{script}"
    action :create_if_missing
    owner node['drupal-solr']['tomcat_user']
    group node['drupal-solr']['tomcat_group']
    mode 0755
  end
end

template "#{node['drupal-solr']['solr_home']}/solr.xml}" do
  owner node['drupal-solr']['tomcat_user']
  group node['drupal-solr']['tomcat_group']
  source 'solr_context.xml.erb'
end


