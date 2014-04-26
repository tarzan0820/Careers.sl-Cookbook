#
# Cookbook Name:: postfix-ses
# Recipe:: default
#
# Copyright (C) 2013 TABLE XI
# 
# All rights reserved - Do Not Redistribute
#

package "openjdk-6-jdk" do
  action :purge
end


package 'openjdk-7-jdk'

group node[:solr_drupal][:tomcat_group]

bash "change_owner" do
  code <<-EOH
    useradd -Mb /usr/local #{node[:solr_drupal][:tomcat_user]} -g #{node[:solr_drupal][:tomcat_group]}
  EOH
end

ark 'tomcat' do
   url node[:solr_drupal][:tomcat_download_link]
   owner node[:solr_drupal][:tomcat_user]
   action :put
end

ark "solr" do
  url node['drupal-solr']['url']
  action :put
  owner node['drupal-solr']['tomcat_user']
end

bash "copy_source_1" do
    code <<-EOH
      cp -r /usr/local/solr/dist/solrj-lib/* /usr/local/tomcat/lib/
      chown -R #{node['drupal-solr']['tomcat_user']}:#{node['drupal-solr']['tomcat_group']} /usr/local/tomcat/lib/
    EOH
end


remote_file "/usr/local/tomcat/conf/log4j.properties" do 
  source "file:///usr/local/solr/example/resources/log4j.properties"
  owner node['drupal-solr']['tomcat_user']
  group node['drupal-solr']['tomcat_group']
  mode 0755
end

remote_file "/usr/local/tomcat/webapps/solr.war" do 
  source "file:///usr/local/solr/dist/solr-#{node['drupal-solr']['solr_version']}.war "
  owner node['drupal-solr']['tomcat_user']
  group node['drupal-solr']['tomcat_group']
  mode 0755
end



template "/usr/local/tomcat/conf/Catalina/localhost/solr.xml" do
  owner node['drupal-solr']['tomcat_user']
  group node['drupal-solr']['tomcat_group']
  source "solr.xml.erb"
end

directory '/usr/local/tomcat/solr' do
  owner node['drupal-solr']['tomcat_user']
  group node['drupal-solr']['tomcat_group']
  mode 0755
  recursive true
end

bash "copy_source_2" do
    code <<-EOH
    cp -r /usr/local/solr/example/solr/collection1/conf /usr/local/tomcat/solr/
    chown -R #{node['drupal-solr']['tomcat_user']}:#{node['drupal-solr']['tomcat_group']} /usr/local/tomcat/solr
    EOH
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
  cookbook_file "/usr/local/tomcat/solr/conf/#{script}" do
    source "#{script}"
    action :create_if_missing
    owner node['drupal-solr']['tomcat_user']
    group node['drupal-solr']['tomcat_group']
    mode 0755
  end
end


bash "change_permissiomn" do
    code <<-EOH
    chown -R #{node['drupal-solr']['tomcat_user']}:#{node['drupal-solr']['tomcat_group']} /usr/local/tomcat/solr/conf
    EOH
end

template "/usr/local/tomcat/solr/solr.xml" do
  owner node['drupal-solr']['tomcat_user']
  group node['drupal-solr']['tomcat_group']
  source 'drupal_context.xml.erb'
end


directory "/usr/local/tomcat/solr/drupal" do
  owner node['drupal-solr']['tomcat_user']
  group node['drupal-solr']['tomcat_group']
  mode 0755
  recursive true
end



bash "copy_source_3" do
    code <<-EOH
    cp -r /usr/local/tomcat/solr/conf /usr/local/tomcat/solr/drupal
    chown -R #{node['drupal-solr']['tomcat_user']}:#{node['drupal-solr']['tomcat_group']} /usr/local/tomcat/solr/drupal
    EOH
end

