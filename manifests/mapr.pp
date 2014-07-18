## MapR Config
#
#

##- Settings -##
$data_dev        = '/dev/sdb'
$data_part       = '/dev/sdb1'
$data_mount      = 'mapr-data'
$data_mountpoint = "/media/$data_mount"




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
  package {['iftop','htop','elinks','stress','nmap','ssh','git','openjdk-7-jdk','python','python-pycurl','sshpass']:
    ensure => present,
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

    ## MapR Installation
    exec {'/usr/bin/wget http://package.mapr.com/releases/v3.1.1/redhat/mapr-setup -O /usr/bin':
      creates => '/usr/bin/mapr-setup'
    }
    file { '/usr/bin/mapr-setup':
      mode   => '0775',
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


}








