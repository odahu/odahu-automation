@include source-config.inc
@include filters-config.inc

<match%{ for prefix in pod_prefixes } kubernetes.var.log.containers.${ prefix }%{ endfor }>
  @type rewrite_tag_filter
  <rule>
    key $.kubernetes.labels.odahu-flow-authorization
    pattern /^enabled/
    tag   opa
    label @opa
  </rule>
  <rule>
    key ModelName
    pattern /^.+/
    tag   deployment
    label @deployment
  </rule>
  <rule>
    key $.kubernetes.namespace_name
    pattern /^odahu-flow.*/
    tag   odahu-flow
    label @odahu-flow
  </rule>
  <rule>
    key log
    pattern /.*/
    tag   $${tag}
    label @kubernetes
  </rule>
</match>

<label @deployment>
  <match **>
    @include elastic-config.inc
    logstash_prefix deployment
  </match>
</label>

<label @opa>
  <match **>
    @include elastic-config.inc
    logstash_prefix opa
  </match>
</label>

<label @odahu-flow>
  <match **>
    @include elastic-config.inc
    logstash_prefix odahu-flow
  </match>
</label>

<label @kubernetes>
  <match **>
    @include elastic-config.inc
  </match>
</label>

<label @FLUENT_LOG>
  <match **>
    @type null
  </match>
</label>

<match **>
  # Drop everything else
  @type null
</match>
