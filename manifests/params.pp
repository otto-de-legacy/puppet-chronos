# Class: chronos::params
#
# Holds all default parameters
class chronos::params {
  $version   = 'installed'
  $package   = 'chronos'
  $options   = { }

  $zk_path_mesos = '/mesos'
  $zk_path_chronos = '/chronos'

  $chronos_dir = '/var/chronos'
}
