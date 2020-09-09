[pg-backup]
type = google cloud storage
bucket_policy_only = true
object_acl = projectPrivate
bucket_acl = projectPrivate
service_account_credentials = ${backup_sa_key}
