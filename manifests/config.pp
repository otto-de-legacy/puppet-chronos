# Class: chronos::config
#
# Configures chronos installation
class chronos::config {

  assert_private()

  $zk_connection_string_mesos = $chronos::zk_connection_string_mesos
  $zk_nodes        = $chronos::zk_nodes
  $zk_path_chronos = $chronos::zk_path_chronos
  $options         = $chronos::options
  $secret          = $chronos::secret

  file { '/etc/systemd/system/chronos.service':
    ensure  => file,
    content => template('chronos/chronos.service.erb'),
    mode    => '0444',
    notify  => Exec['systemctl-daemon-reload_chronos'],
  }

  exec { 'systemctl-daemon-reload_chronos':
    command     => 'systemctl daemon-reload',
    refreshonly => true,
  }

  # TODO PR for setting chronos args via environment: https://github.com/mesosphere/chronos-pkg/pull/17
  file { '/etc/sysconfig/chronos':
    ensure  => file,
    content => template('chronos/sysconfig.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
  }

  if ($secret) {
    file { '/root/.credentials_chronos':
      ensure  => present,
      content => $secret,
      owner   => 'root',
      group   => 'root',
      mode    => '0400',
    }
  }
}
