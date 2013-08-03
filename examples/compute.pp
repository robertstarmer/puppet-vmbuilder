class {"vmbuilder":
	mirror=>"http://rtp-linux.cisco.com/ubuntu",
        firstboot=>true,
	network=>"172.29.84.0",
	netmask=>"255.255.255.192",
	gateway=>"172.29.84.1",
	ip=>"172.29.84.42",
	dns=>"172.29.84.40",
	hostname=>"compute10",
	domain=>"lab",
	disk=>"32768",
	memory=>"4096",
	bridge=>"br-ex",
	puppetmaster=>"build-server.lab" }
