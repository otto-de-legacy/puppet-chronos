# Class: chronos::config
#
# Configures chronos installation
class chronos::config {

  assert_private()

  $zk_connection_string_mesos = $chronos::zk_connection_string_mesos
  $zk_path  = $chronos::zk_path
  $options  = $chronos::options
  $secret   = $chronos::secret

  # TODO PR for setting chronos args via environment: https://github.com/mesosphere/chronos-pkg/pull/17
  file { '/etc/sysconfig/chronos':
    ensure  => file,
    content => template('chronos/sysconfig.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    notify  => Service['chronos'],
  }

  if ($secret) {
    file { '/root/.credentials_chronos':
      ensure  => present,
      content => $secret,
      owner   => 'root',
      group   => 'root',
      mode    => '0400',
      notify  => Service['chronos']
    }
  }
}
