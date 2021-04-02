<filter kubernetes.**>
  @type record_transformer
  enable_ruby
  <record>
    event_time $${time.strftime('%Y-%m-%dT%H:%M:%S.%NZ')}
  </record>
</filter>

<filter kubernetes.**>
  @type kubernetes_metadata
  @id filter_kube_metadata
  kubernetes_url "#{ENV['FLUENT_FILTER_KUBERNETES_URL'] || 'https://' + ENV.fetch('KUBERNETES_SERVICE_HOST') + ':' + ENV.fetch('KUBERNETES_SERVICE_PORT') + '/api'}"
  verify_ssl "#{ENV['KUBERNETES_VERIFY_SSL'] || true}"
  ca_file "#{ENV['KUBERNETES_CA_FILE']}"
</filter>

<filter kubernetes.**>
  @type parser
  key_name log
  reserve_data true
  <parse>
    @type grok
    grok_failure_key grokfailure
    <grok>
      pattern \"modelName\":\"(?<ModelName>[a-zA-F0-9_-]+)\"
    </grok>
    <grok>
      pattern \/model\/(?<ModelName>[a-zA-F0-9_-]+)\/api\/model\/
    </grok>
    <grok>
      pattern \"knative.dev\/key\":\"odahu-flow-deployment\/(?<mn_knative>[a-zA-F0-9_-]+)\"
    </grok>
  </parse>
</filter>

<filter kubernetes.**>
  @type record_transformer
  enable_ruby
  <record>
    event_time $${time.strftime('%Y-%m-%dT%H:%M:%S.%NZ')}
    ModelName "$${\
            if record['ModelName']
              record['ModelName']
            elsif record['md_id']
              record['md_id']
            elsif record['kubernetes']
              if record['kubernetes']['labels']
                if record['kubernetes']['labels']['modelName']
                  record['kubernetes']['labels']['modelName']
                end
              end
            elsif record['mn_knative']
              record['mn_knative']
            end}"
  </record>
</filter>
