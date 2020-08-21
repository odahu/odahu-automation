@type gcs
auto_create_bucket false
bucket "${data_bucket}"
object_key_format "%%{path}/%%{index}.%%{file_extension}"
store_as text
utc
