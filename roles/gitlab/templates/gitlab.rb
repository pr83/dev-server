# AWS Backups
gitlab_rails['backup_upload_connection'] = {
  'provider' => '{{ item.backup.provider }}',
  'region' => '{{ item.backup.region }}',
  'aws_access_key_id' => '{{ item.backup.accessKeyId }}',
  'aws_secret_access_key' => '{{ item.backup.secretAccessKey }}'
}

{% if item.backup.host is defined %}
  gitlab_rails['backup_upload_connection']['host'] = "{{ item.backup.host }}"
{% endif %}

{% if item.backup.endpoint is defined %}
  gitlab_rails['backup_upload_connection']['endpoint'] = "{{ item.backup.endpoint }}"
  gitlab_rails['backup_upload_connection']['path_style'] = true
{% endif %}

gitlab_rails['backup_upload_remote_directory'] = '{{ item.backup.uploadRemoteDirectory }}'

# Base URL
external_url '{{ baseUrl }}'
# the options below are there because mentioning https:// in the external_parameter has
# the side effect of changing the GitLab nginx configuration, but we don't want that, since
# we use our own nginx instance as a proxy, not the nginx which is a part of GitLab itself
nginx['listen_port'] = 80
nginx['listen_https'] = false