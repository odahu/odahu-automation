@include source-config.inc
@include filters-config.inc

<match%{ for prefix in pod_prefixes } kubernetes.var.log.containers.${ prefix }%{ endfor }>
  @include cloud-config.inc

  path "logs/%Y/%m/%d/#{ENV['FLUENTD_NODE_NAME']}/containers/$${tag}"
  time_slice_format %Y%m%d%H

  # Buffering
  <buffer hostname,tag,time>
    @type file
    path /tmp/kubernetes
    timekey 1m
    timekey_wait 0s
    timekey_use_utc true
  </buffer>

  # Formatting
  <format>
    @type json
  </format>
</match>

<match **>
  # Drop everything else
  @type null
</match>
