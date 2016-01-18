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
# [*secret*]          - secret for connecting to mesos, (default: undef)
class chronos (
  $zk_nodes,
  $package          = $params::package,
  $version          = $params::version,
  $zk_path_mesos    = $params::zk_path_mesos,
  $zk_path_chronos  = $params::zk_path_chronos,
  $enable_service   = true,
  $options          = $params::options,
  $secret           = undef,
) inherits chronos::params {

  # validate input
  validate_array($zk_nodes)
  validate_absolute_path($zk_path_mesos)
  validate_absolute_path($zk_path_chronos)
  validate_string($package)
  validate_bool($enable_service)
  validate_hash($options)

  # buid zk connecton strings
  $zk_nodes_string = join($zk_nodes, ',')
  $zk_connection_string = "zk://${zk_nodes_string}"
  # for mesos
  $zk_connection_string_mesos = "${zk_connection_string}${zk_path_mesos}"

  Class['install']
  -> Class['config']
  ~> Class['service']

  include install, config, service
}
