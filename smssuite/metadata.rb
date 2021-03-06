name             "smssuite"
maintainer       "Salton Massally"
maintainer_email "salton.massally@gmail.com"
license          "MIT"
description      "Installs/Configures the careers.sl sms suite"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

%w[ubuntu].each do |os|
  supports os
end

%w{ python gunicorn supervisor memcached celery}.each do |cb|
  depends cb
end
