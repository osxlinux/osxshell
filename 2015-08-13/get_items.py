#!/usr/bin/python
#coding:utf8

import os
import sys
import json
import urllib2
import zablogin

class get_infor(object):
    def __init__(self):
        self.auid = zablogin.main()
    def get_test(self):
        data = json.dumps({
            "jsonrpc": "2.0",
            "method": "host.get",
            "params": {
                 "output": "extend",
             },
            "auth": self.auid,
            "id": 1
            })
        self.re = zablogin.ReData(data)
        for x in self.re['result']:
            print x['host'],x['hostid'],x['status'],x['name']

def main():
    result = get_infor()
    return result.get_test()
if __name__ == "__main__":
    main()

