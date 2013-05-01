class vmbuilder (
 $distribution = 'precise',
 $firstboot = undef,
 $mirror = undef,
 $network = '192.168.1.0',
 $netmask = '255.255.255.0',
 $gateway = '192.168.1.1',
 $ip = '192.168.1.254',
 $dns = '171.70.168.183',
 $hostname = 'build-server',
 $domain = 'example.com',
 $disk = '8192',
 $memory = '4096',
 $bridge = 'br-ex',
 $puppetmaster ='build-server.example.com',
) {

  package { ['python-vm-builder','virt-manager','virt-viewer','gnome-core','vnc4server']:
   ensure => 'latest',
#   notify => Exec["vmbuild-kvm-ubuntu"],
  }

  file { "/etc/modprobe.d/kvm-intel.conf":
   ensure => 'present',
   content => 'options kvm-intel nested=1',
  }
  file { "/etc/vmbuilder.cfg":
   ensure => 'present',
   content => template("vmbuilder/vmbuilder.cfg.erb"),
  }

  file { "/etc/vmbuilder.part":
   ensure => 'present',
   content => template("vmbuilder/vmbuilder.part.erb"),
  }

  file { "/etc/vmbuilder.boot.sh":
   ensure => 'present',
   content => template("vmbuilder/vmbuilder.boot.sh.erb"),
  } 

  file { "/vms":
    ensure => 'directory',
  } 
  if $firstboot {
   exec { "vmbuild-kvm-$hostname":
    path => ["/usr/bin","/bin","/sbin"],
    timeout => '1200',
    command => "vmbuilder kvm ubuntu --firstboot=/etc/vmbuilder.boot.sh --mask $netmask --net $network --gw $gateway --dns $dns --hostname=$hostname --destdir=/vms/$hostname --ip $ip",
    unless => "test -d /vms/$hostname",
    require => File["/vms"],
   }
  } else {
   exec { "vmbuild-kvm-$hostname":
    path => ["/usr/bin","/bin","/sbin"],
    timeout => '1200',
    command => "python vmbuilder kvm ubuntu  --mask $netmask --net $network --gw $gateway --dns $dns --hostname=$hostname --destdir=/vms/$hostname --ip $ip",
    unless => "test -d /vms/$hostname",
    require => File["/vms"],
   }
  }
  file { '/root/.vnc/':
    ensure => 'directory',
  } ->
  file { '/root/.vnc/xstartup':
    ensure => present,
    mode => 0644,
    content => "#!/bin/sh

unset SESSION_MANAGER
gnome-session –session=gnome-classic &

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
vncconfig -iconic &
"
    }

}
