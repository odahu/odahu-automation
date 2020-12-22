@type s3
<web_identity_credentials>
  role_arn "${iam_role_arn}"
  role_session_name odahu_fluentd
  web_identity_token_file /var/run/secrets/eks.amazonaws.com/serviceaccount/token
</web_identity_credentials>
s3_bucket "${data_bucket}"
s3_region "${data_bucket_region}"
s3_object_key_format "%%{path}/%%{index}.%%{file_extension}"
store_as text
utc
