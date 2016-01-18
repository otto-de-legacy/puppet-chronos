# Class: chronos::install
#
# Installs chronos
class chronos::install {

  assert_private()

  $package = $chronos::package
  $version = $chronos::version
  $chronos_dir = $chronos::params::chronos_dir

  package { $package:
    ensure => $version,
    notify => Class['chronos::service'],
  }

  file { [
    '/var/opt/chronos/',
    '/var/opt/chronos/conf',
    '/var/opt/chronos/jobs',
  ]:
    ensure  => directory,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Package[$package],
  }

  # Remove config installed by vendor rpm
  file { '/etc/chronos':
    ensure  => absent,
    force   => true,
    recurse => true,
  }
}
