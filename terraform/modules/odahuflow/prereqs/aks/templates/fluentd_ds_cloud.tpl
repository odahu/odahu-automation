@type azure-storage-append-blob
azure_storage_account "#{ENV['AZURE_STORAGE_ACCOUNT']}"
azure_storage_sas_token "#{ENV['AZURE_STORAGE_SAS_TOKEN']}"
azure_container "${data_bucket}"
azure_object_key_format "%%{path}/%%{index}.%%{file_extension}.txt"
auto_create_container "true"
