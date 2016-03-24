# Class: chronos
#
# This module manages chronos installation
#
# Parameters:
#
# [*zk_nodes*]        - array of zookeeper hosts - mandatory
# [*package*]         - chronos package name, (default: 'chronos')
# [*version*]         - install specific version of chronos, (default: 'installed')
# [*zk_path_mesos*]   - zookeeper path for finding mesos master, (default: '/mesos')
# [*zk_path_chronos*] - zookeeper path for storing chronos state, (default: '/chronos')
# [*enable_service*]  - enable chronos service, (default: true)
# [*options*]         - additional command line options, (default: {})
# [*java_home*]       - set JAVA_HOME, (default: undef)
# [*run_as_user*]     - run service under specified user, (default: undef)
# [*secret*]          - secret for connecting to mesos, (default: undef)
class chronos (
  $zk_nodes,
  $package          = $chronos::params::package,
  $version          = $chronos::params::version,
  $zk_path_mesos    = $chronos::params::zk_path_mesos,
  $zk_path_chronos  = $chronos::params::zk_path_chronos,
  $enable_service   = true,
  $options          = $chronos::params::options,
  $env_var          = $chronos::params::env_var,
  $java_home        = undef,
  $run_as_user      = undef,
  $secret           = undef,
) inherits chronos::params {

  # validate input
  validate_array($zk_nodes)
  validate_absolute_path($zk_path_mesos)
  validate_absolute_path($zk_path_chronos)
  validate_string($package)
  validate_bool($enable_service)
  validate_hash($options)
  validate_hash($env_var)

  # buid zk connecton strings
  $zk_nodes_string = join($zk_nodes, ',')
  $zk_connection_string = "zk://${zk_nodes_string}"
  # for mesos
  $zk_connection_string_mesos = "${zk_connection_string}${zk_path_mesos}"

  # Contain with Anchor Pattern
  anchor { 'chronos_first': }
  -> Class['::chronos::install']
  -> Class['::chronos::config']
  ~> Class['::chronos::service']
  -> anchor { 'chronos_last': }

  include ::chronos::install, ::chronos::config, ::chronos::service
}
