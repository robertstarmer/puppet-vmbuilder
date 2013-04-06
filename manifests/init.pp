class vmbuild (
 $distribution = 'precise',
 $mirror = undef,
 $network = '192.168.1.0',
 $netmask = '255.255.255.0',
 $gateway = '192.168.1.1',
 $ip = '192.168.1.254',
 $dns = '171.70.168.183',
 $hostname = 'build-server',
 $domain = 'example.com',
 $disk = '8192',
 $ram = '4096',
 $bridge = 'br0',
) {

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
  exec { "vmbuild-kvm-$hostname":
   path => ["/usr/bin","/bin","/sbin"],
   #command => "vmbuilder kvm ubuntu --mask 255.255.255.0 --net 192.168.40.0 --bcast 192.168.40.255 --gw 192.168.40.1 --dns 192.168.40.254 --firstboot=/etc/vmbuilder.boot.sh --hostname=build-vm --destdir=/vms/build-vm --ip 192.168.40.5",
   command => "vmbuilder kvm ubuntu --firstboot=/etc/vmbuilder.boot.sh --mask $netmask --net $net --gw $gateway --dns $dns --hostname=$hostname --destdir=/vms/$hostname --ip $ip,
   unless => "test -d /vms/$hostname",
  }
}
