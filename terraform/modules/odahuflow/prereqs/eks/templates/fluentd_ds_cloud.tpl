@type s3
<web_identity_credentials>
</web_identity_credentials>
s3_bucket "${data_bucket}"
s3_region "${data_bucket_region}"
s3_object_key_format "%%{path}/%%{index}.%%{file_extension}"
store_as text
utc
