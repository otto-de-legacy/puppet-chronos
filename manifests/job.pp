# Define: chronos::job
#
# This module manages chronos jobs
#
# Parameters:
#  [*ensure*]  - present -> creates chronos job; absent -> removes chronos job
#  [*content*] - chronos job API json
#
# Should not be called directly
#
define chronos::job(
  $content,
  $ensure = present,
) {

  $safe_name = regsubst(regsubst($title, '^\/', ''), '\/', '_', 'G')
  $file_name = "${safe_name}.json"
  $file_path = "/var/opt/chronos/jobs/${$file_name}"

  if ($ensure == 'present') {
    file { $file_path:
      ensure  => file,
      content => $content,
    }

    exec { "chronos-deploy-${safe_name}":
      command => "curl -H 'Content-Type: application/json' -X POST http://localhost:8081/scheduler/iso8601 -d@${file_path} || true",
      require => [File[$file_path], Class['chronos']],
    }

  } else {
    file { $file_path:
      ensure => absent,
    }

    exec { "chronos-destroy-${safe_name}":
      command => "curl -H 'Content-Type: application/json' -X DELETE http://localhost:8081/scheduler/job/${safe_name} || true",
    }
  }
}