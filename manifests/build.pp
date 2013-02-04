define vmbuilder::build(
$os='ubuntu',
$vmm='kvm',
$ip='192.168.25.10',
$mask='255.255.255.0',
$gateway='192.168.25.1',
$dns='192.168.25.1',
$firstboot='/etc/vmbuilder.boot.sh',
$hostname='vmbuilt',
$destdir='/vmbuilt',
){
exec{"build":
  command=>"vmbuilder ${vmm} ${os} --mask ${mask} --gw ${gateway} --dns ${dns} --firstboot=${firstboot} --hostname=${hostname} --destdir=${destdir} --ip ${ip}",
  ensure=>'present',
  unless=>'/bin/ls /vmbuilt/',
  }

}
