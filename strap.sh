#!/bin/bash

rpm -ivh http://yum.puppetlabs.com/el/6/products/i386/puppetlabs-release-6-7.noarch.rpm
yum install -y puppet
service puppet start
chkconfig puppet on 


puppet module install thias-sysctl
puppet module install thias-tuned
puppet module install puppetlabs-motd
puppet module install puppetlabs-mysql
