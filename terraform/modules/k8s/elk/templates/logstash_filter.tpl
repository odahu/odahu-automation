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
    match => { "log" => "\"knative.dev\/key\":\"odahu-flow-deployment\/(?<mn_knative>[a-zA-F0-9_-]+)\"" }
  }
  grok {
    match => { "log" => " \/model\/(?<ModelName>[a-zA-F0-9_-]+)\/api\/model\/" }
  }
  if [md_id] {
    mutate {
      copy => { "md_id" => "ModelName" }
    }
  }
  if [kubernetes][labels][modelName] {
    mutate {
      copy => { "[kubernetes][labels][modelName]" => "ModelName" }
    }
  } else if [mn_knative] {
    if [logger][controller][revision-gc-controller][knative] or [logger][controller][configuration-controller][knative] {
      mutate {
        copy => { "[mn_knative]" => "ModelName" }
      }
    }
  }
  if [ModelName] {
    mutate {
      add_field => { "[@metadata][target_index]" => "deployment" }
    }
  } else if [kubernetes][namespace_name] in [ "odahu-flow-training", "odahu-flow-packaging", "odahu-flow-deployment" ] {
    mutate {
      add_field => { "[@metadata][target_index]" => "odahu-flow" }
    }
  } else {
    if [kubernetes][labels][odahu-flow-authorization] == "enabled" {
      mutate {
        add_field => { "[@metadata][target_index]" => "opa" }
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
