<source>
  @type tail
  @id in_tail_container_logs
  path /var/log/containers/*.log
  pos_file /var/log/fluentd-containers.log.pos
  tag kubernetes.*
  read_from_head true
  <parse>
    @type "#{ENV['FLUENT_CONTAINER_TAIL_PARSER_TYPE'] || 'json'}"
    time_format %Y-%m-%dT%H:%M:%S.%NZ
  </parse>
</source>
