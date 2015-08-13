#!/usr/bin/env python
#auth:seraphico
#email:
import json
import urllib2
from urllib2 import URLError
import os
import sys

class login_get(object):

    def __init__(self):
        self.url = "http://127.0.0.1/api_jsonrpc.php"
        self.user = "xxxxxxxxx"
        self.password="xxxxxxxxxx" 
        self.header = {"Content-Type": "application/json"}
        self.authID = self.user_login()

    def user_login(self):
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "user.login",
            "params": {
                "user": self.user,
                "password": self.password
                      },
            "id": 0
		})
        request = urllib2.Request(self.url,data)
        for key in self.header:
            request.add_header(key,self.header[key])
        try:
            result = urllib2.urlopen(request)
        except Exception as e:
            print "Auth Failed, Please Check Your Name And Password:",e.code
        else:
            response = json.loads(result.read())
            result.close()
            authID = response['result']
            return authID
    def get_data(self,data,hostip=""):
        request = urllib2.Request(self.url,data,self.header)
        try:
            result = urllib2.urlopen(request)
        except Exception as e:
            if hasattr(e, "reason"):
                print "Failed to reach a server."
                print "Reason:", e.reason
            elif hasattr(e, "reason"):
                print 'The server could not fulfill the request.'
                print 'Error code: ', e.code
            return 0
        else:
            response = json.loads(result.read())
            result.close()
            return response

login = login_get()
def main():
    userid = login.user_login()
    return  userid
def ReData(data):
    re_data = login.get_data(data)
    return re_data   
if __name__ == "__main__":
    main()
