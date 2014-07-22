## MapR Config
#
#

##- Settings -##
$data_dev        = '/dev/sdb'
$data_part       = '/dev/sdb1'
$data_mount      = 'mapr-data'
$data_mountpoint = "/media/$data_mount"

if versioncmp($::puppetversion,'3.6.1') >= 0 {
  $allow_virtual_packages = hiera('allow_virtual_packages',false)
  Package {
    allow_virtual => $allow_virtual_packages,
  }
}

define appendLineToFile($file, $line, $user) {
  exec { "echo \"\\n$line\" >> \"$file\"":
    path   => '/bin',
    unless => "grep -Fx \"$line\" \"$file\"",
    user   => $user,
  }
}


## All Nodes

node default {
  ## Standard Packages
  package {['iftop','htop','elinks','stress','nmap','openssh-server','git','java-1.7.0-openjdk','python','python-pycurl','sshpass','wget']:
    ensure => present,
  }
  service{'sshd':
    ensure => running,
  }

  ## Debian/Ubuntu Specific
  if $operatingsystem =~ /^(Debian|Ubuntu)$/  {
    ## Prereq Packages
    package {['libssl0.9.8',]:
      ensure => present,
    }


  }

  ## RHEL/CentOS Specific
  if $operatingsystem =~ /^(RedHat|CentOS)$/  {
    ## Prereq Packages
    package {['libselinux-python','openssl098e','openssh-clients']:
      ensure => present,
    }
    package {'epel':
      ensure   => present,
      source   => 'http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm',
      provider => 'rpm',
    }

    ## MapR Installation
    exec {'mapr-setup':
      command => '/usr/bin/wget http://package.mapr.com/releases/v3.1.1/redhat/mapr-setup -O /usr/bin/mapr-setup ; /usr/bin/mapr-setup',
      creates => '/opt/mapr-installer',
      #notify  => File['/usr/bin/mapr-install']
    }
    file { '/usr/bin/mapr-install':
      ensure  => present,
      mode    => '0755',
      content => '#!/bin/bash
cwd=$PWD
cd /opt/mapr-installer/bin/
./install
cd $cwd
',
      #ensure    => link,
      #target    => "/opt/mapr-installer/bin/install",
      #source    => "/opt/mapr-installer/bin/install",
      #subscribe => Exec["mapr-setup"]
    }
    file { '/usr/bin/mapr-setup':
      mode   => '0777',
      #ensure => present
    }
  }


  ## Disk Tests
  file {'/usr/bin/mapr-test-read':
    ensure  => present,
    mode    => '0775',
    content => "#!/bin/bash
                hdparm -Tt $data_dev
                dd iflag=nonblock, direct if=$data_dev bs=1M count=10240 1>/dev/null"
  }
  file {'/usr/bin/mapr-test-write':
    ensure  => present,
    mode    => '0775',
    content => "#!/bin/bash
               dd oflag=nonblock,direct if=/dev/zero bs=1M count=10240 of=$data_dev 1>/dev/null"
  }

  file {'/etc/issue':
    ensure => present,
    content =>'
___  ___           ______ 
|  \/  |           | ___ \
| .  . | __ _ _ __ | |_/ /
| |\/| |/ _` | '_ \|    / 
| |  | | (_| | |_) | |\ \ 
\_|  |_/\__,_| .__/\_| \_|
             | |          
             |_|          
                          
       Node \s
'
  }


}








