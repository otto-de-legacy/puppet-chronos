# Class: chronos::service
#
# Manages chronos service
class chronos::service {

  assert_private()

  $options = $chronos::options
  $enable_service = $chronos::enable_service
  $ensure_service = $enable_service ? {
    true  => 'running',
    false => 'stopped',
  }

  file { '/etc/systemd/chronos.service.erb':
    ensure  => file,
    content => template('chronos/chronos.service.erb'),
    mode    => '0444',
    notify  => Exec['systemctl-daemon-reload_chronos'],
  }

  exec { 'systemctl-daemon-reload_chronos':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }

  service { 'chronos':
    ensure  => $ensure_service,
    enable  => $enable_service,
    require => Exec['systemctl-daemon-reload_chronos'],
  }
}
