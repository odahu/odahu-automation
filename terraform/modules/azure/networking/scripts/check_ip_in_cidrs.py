#!/usr/bin/env python3

import sys, ipaddress, json

def query_args(obj):
  """Load json object from stdin."""
  return {} if obj.isatty() else json.load(obj)

def out_json(result):
  """Print result to stdout."""
  print(json.dumps(result))

def main(**kwargs):
  # `kwargs` contains the query args passed from Terraform
  ip = str(kwargs['ip'])
  in_list = str(kwargs['cidrlist'])
  out_list = []

  for i in in_list.split(", "):
    if ipaddress.IPv4Address(ip) not in ipaddress.IPv4Network(i):
      out_list.append(i.replace("/32", ""))

  out_list.append(ip)

  return str(', '.join(out_list))

if __name__ == '__main__':
  args = query_args(sys.stdin)
  sys.exit(out_json({'cidrlist': main(**args)}))
