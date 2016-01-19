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

  service { 'chronos':
    ensure => $ensure_service,
    enable => $enable_service,
  }
}
