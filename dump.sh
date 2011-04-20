sudo tcpdump -l -A -i en1 'tcp port 88 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'
