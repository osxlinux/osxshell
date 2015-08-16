#!/usr/bin/env python
import socket
import sys
import time

TMOUT= 2
PORT = 80
HOST = 'x.x.x.x'
socket.setdefaulttimeout(TMOUT)
try:
	s = socket.socket(socket.AF_INET,socket.SOCK_STREAM)
except socket.error, msg:
	print "Failed to create socke, Error code:" + str(msg[0]) + "Error";
	sys.exit();
#print "socket created "
try:
	remote_ip =  socket.gethostbyname(HOST)
except socket,gaierrot:
	print "Hostname clould not be resolved.Exiting"
	sys.exit()
#print "IP address of " + host + 'is ' + remote_ip 
try:
	s.connect((remote_ip,PORT))
except:
	print 0
else:
	print 1
finally:
	s.close()
	sys.exit()

