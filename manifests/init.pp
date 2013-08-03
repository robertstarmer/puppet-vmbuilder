class vmbuilder (
  $distribution = 'precise',
  $arch         = 'amd64',
  $mirror       = undef,
  $virtio_net   = true,
  $ip           = undef,
  $network      = undef,
  $netmask      = undef,
  $gateway      = undef,
  $dns          = undef,
  $hostname     = 'build-server',
  $domain       = 'example.com',
  $disk         = '8192',
  $cpus         = '2',
  $memory       = '4096',
  $bridge       = 'br-ex',
  $puppetmaster = 'build-server.example.com',
  $disk_path    = '/vms',
  $user         = 'localadmin',
  $pass         = 'ubuntu',
  $firstboot    = '/etc/vmbuilder.boot.sh',
  $raw          = undef,
  $tty          = true,
  $part         = undef,
  $ssh_rsa_key  = 'AAAAB3NzaC1yc2EAAAADAQABAAABAQCeS9zlMeXeivRadLQPLkKevr4wgwckKWr7/M2duvAwNNUmksQTwdfgyA9olciY4LAtn1CRFt4eU7gXOkbP9c0iUTvn/R7Rsva29W/NyXAKIF56PEEZ77FHlXyifuOgRiaRHZMz7sbMFsiXhgwwOl/fsA8pCGOo7VZ5Y088Bwcec0xpm8doxgTZoHtBGcskYX3OiAcYr/dJqzvJmtPwTUtjpWlk9pTSrnedxgKh9XKndKEE3ewjsTAmtpAkdw5gdaUCmJMM4U+o86QIxTNy67ITjoFnsNlspxDiTlrPGn8D6Xt4VLWvus8WbeR5Rv9vz+WPHJT0nMnrsG0hnVCDLe2p root@control01',
  $sudo         = true,
  $ntpsync      = true,
  $timezone     = undef,
  $components   = [ main,
                    universe,
                    restricted,
                    multiverse ],
  $pkg          = [ openssh-server,
                    acpid,
                    ntp,
                    puppet,
                    ipmitool,
                    git,
                    python-passlib,
                    python-yaml,
                    python-jinja2,
                    vim,
                    telnet,
                    tcpdump,
                    tmux,
                    lvm2,
                    iptables,
                    iputils-tracepath,
                    bash-completion,
                    aptitude,
                    ufw,
                    dbus,
                    curl,
                    command-not-found,
                    command-not-found-data ],
) {

  if $::operatingsystem == 'Ubuntu' {
    $pkg_full = $pkg + [ 'python-software-properties' ]
  } else {
    $pkg_full = $pkg
  }


  package { [ 'python-vm-builder',
              'virt-manager',
              'virt-viewer',
              'gnome-core',
              'vnc4server']:
    ensure => 'latest',
  }

  file { '/etc/modprobe.d/kvm-intel.conf':
    ensure  => 'present',
    content => 'options kvm-intel nested=1',
  }

  file { '/etc/vmbuilder.cfg':
    ensure  => 'present',
    content => template('vmbuilder/vmbuilder.cfg.erb'),
  }

  if $part != indef {
    file { '/etc/vmbuilder.part':
      ensure  => 'present',
      content => template('vmbuilder/vmbuilder.part.erb'),
    }

    $part_option = '--part /etc/vmbuilder.part'
  } else {
    $part_option = ''
  }

  file { '/etc/vmbuilder.boot.sh':
    ensure  => 'present',
    content => template('vmbuilder/vmbuilder.boot.sh.erb'),
  }

  file { '/etc/vmbuilder/libvirt/libvirtxml.tmpl':
    ensure  => 'present',
    content => template('vmbuilder/libvirtxml.tmpl.erb'),
    require => Package['virt-manager'],
  }

  file { $disk_path:
    ensure => 'directory',
  }

  if $raw != undef {
    $raw_options = "--raw $raw"
  } else {
    $raw_options = ''
  }

  if $firstboot {
    $firstboot_option = '--firstboot=/etc/vmbuilder.boot.sh'
  } else {
    $firstboot_option = ''
  }

  if $network != undef {
    $network_option = "--net $network"
  } else {
    $network_option = ''
  }

  if $timezone != undef {
    $timezone_option = "--timezone $timezone"
  } else {
    $timezone_option = ''
  }

  $options = [  "--mask $netmask",
                "--gw $gateway",
                "--dns $dns",
                "--hostname=$hostname",
                "--destdir=$disk_path/$hostname",
                "--ip $ip",
                "--cpus $cpus",
                "--domain $domain",
              $firstboot_option,
              $raw_options,
              $network_option,
              $timezone_option,
              $part_option ]

  $cmd = "sudo vmbuilder kvm ubuntu ${options.delete("").join(" ")}"

  exec { "vmbuild-kvm-$hostname":
    path      => ['/usr/bin','/bin','/sbin','/usr/sbin'],
    timeout   => '3000',
    command   => $cmd,
    unless    => "test -d $disk_path/$hostname",
    require   => File[$disk_path,'/etc/vmbuilder/libvirt/libvirtxml.tmpl'],
    logoutput => 'true',
  }

  file { '/root/.vnc/':
    ensure => 'directory',
  } ->
  file { '/root/.vnc/xstartup':
    ensure  => present,
    mode    => '0644',
    require => File['/root/.vnc/'],
    content => '#!/bin/sh

unset SESSION_MANAGER
gnome-session –session=gnome-classic &

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
vncconfig -iconic &
'
    }
}
