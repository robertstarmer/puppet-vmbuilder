class {"vmbuilder":
	mirror=>"http://rtp-linux.cisco.com/ubuntu",
	network=>"192.168.1.0",
	netmask=>"255.255.255.0",
	gateway=>"192.168.1.1",
	ip=>"192.168.1.0",
	dns=>"192.168.1.1",
	hostname=>"build-server",
	domain=>"lab",
	disk=>"16384",
	ram=>"4096",
	bridge=>"br-ex",
	puppetmaster=>"build-server.lab" }
