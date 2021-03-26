output {
  elasticsearch {
    hosts => ["${es_service_url}"]
    index => "%%{[@metadata][target_index]}"
    manage_template => false
  }
}
