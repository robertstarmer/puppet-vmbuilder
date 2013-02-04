class vmbuild {

  package { ['python-vm-builder','virt-manager','virt-viewer','gnome-core','vnc4server']:
   ensure => 'latest',
#   notify => Exec["vmbuild-kvm-ubuntu"],
  }

  file { "/etc/vmbuilder.cfg":
   ensure => 'present',
   content => template("vmbuild/vmbuilder.cfg.erb"),
  }

  file { "/etc/vmbuilder.part":
   ensure => 'present',
   content => template("vmbuild/vmbuilder.part.erb"),
  }

  file { "/etc/vmbuilder.boot.sh":
   ensure => 'present',
   content => template("vmbuild/vmbuilder.boot.sh.erb"),
  } 

  file { "/vms":
    ensure => 'directory',
  } ->
  exec { "vmbuild-kvm-ubuntu":
   path => ["/usr/bin","/bin","/sbin"],
   #command => "vmbuilder kvm ubuntu --mask 255.255.255.0 --net 192.168.40.0 --bcast 192.168.40.255 --gw 192.168.40.1 --dns 192.168.40.254 --firstboot=/etc/vmbuilder.boot.sh --hostname=build-vm --destdir=/vms/build-vm --ip 192.168.40.5",
   command => "vmbuilder kvm ubuntu --mask 255.255.255.0 --net 192.168.40.0 --bcast 192.168.40.255 --gw 192.168.40.1 --dns 192.168.40.254 --hostname=build-vm --destdir=/vms/build-vm --ip 192.168.40.5",
   unless => "test -d /vms/build-vm",
#   refreshonly => true,
  }
}
