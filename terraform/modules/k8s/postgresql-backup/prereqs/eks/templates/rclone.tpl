[pg-backup]
type = s3
provider = AWS
env_auth = true
region = ${region}
acl = private
server_side_encryption = AES256
storage_class = STANDARD
