filter {
  json{
    source => "message"
  }
  json{
    source => "log"
  }
  grok {
    match => { "msg" => "\"modelName\":\"(?<ModelName>[a-zA-F0-9_-]+)\"" }
  }
  grok {
    match => { "knative.dev\/key" => "odahu-flow-deployment\/(?<ModelName>[a-zA-F0-9_-]+)" }
  }
  grok {
    match => { "log" => " \/model\/(?<ModelName>[a-zA-F0-9_-]+)\/api\/model\/" }
  }
  if [kubernetes][namespace_name] in [ "odahu-flow-training", "odahu-flow-packaging", "odahu-flow-deployment" ] {
    mutate {
      add_field => { "[@metadata][target_index]" => "odahu-flow" }
    }
  } else {
    if [md_id] {
      mutate {
        rename => ["md_id", "ModelName" ]
      }
    } 
    if [ModelName] {
      mutate {
        add_field => { "[@metadata][target_index]" => "deployment" }
      }
    } else {
      mutate {
        add_field => { "[@metadata][target_index]" => "logstash" }
      }
    }
  }

  ruby {
    code => "event.set('event_time', event.get('@timestamp'));"
  }
}
