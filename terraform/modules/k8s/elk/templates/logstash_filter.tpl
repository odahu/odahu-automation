filter {
  if [kubernetes][namespace_name] in [ "odahu-flow-training", "odahu-flow-packaging", "odahu-flow-deployment"] {
    mutate {
      add_field => { "[@metadata][target_index]" => "odahu-flow" }
    }
  } else {
    mutate {
      add_field => { "[@metadata][target_index]" => "logstash" }
    }
  }

  ruby {
    code => "event.set('event_time', event.get('@timestamp'));"
  }
}
