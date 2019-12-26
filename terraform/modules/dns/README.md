Variables:

managed_zone - Name of existing cloud managed zone that should be used to create DNS records in
domain       - Domain name for DNS records, should be passed if `managed_zone` does't exist, will create zone for you.
  E.x.: if you pass domain="test.example.com", it will try to create DNS zone `test.example.com` named `test-example-com`
records      - list of maps of records to create, e.x.:
  records = [{"name": "bastion", "value": "192.168.0.1"}, {"name": "gateway", "value": "192.168.0.2", "ttl": 120}, {"name": "www", "value": "gateway.test.com", "type": "CNAME"}]

