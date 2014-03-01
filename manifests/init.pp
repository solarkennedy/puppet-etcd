# == Class: etcd
#
# Installs and configures etcd.
#
# === Parameters
#
# === Examples
#
#  class { etcd: }
#
# === Authors
#
# Kyle Anderson <kyle@xkyle.com>
#
class etcd (
  $service_ensure          = 'running',
  $service_enable          = true,
  $use_upstart             = true,
  $package_ensure          = 'installed',
  $package_name            = 'etcd',
  $manage_user             = true,
  $manage_data_dir         = true,
  $user                    = 'etcd',
  $addr                    = "${::fqdn}:4001",
  $bind_addr               = $addr,
  $ca_file                 = '',
  $cert_file               = '',
  $cors                    = [],
  $cpu_profile_file        = '',
  $data_dir                = '/var/lib/etcd',
  $key_file                = '',
  $discovery               = false,
  $peers                   = false,
  $peers_file              = false,
  $max_cluster_size        = '9',
  $max_result_buffer       = '1024',
  $max_retry_attempts      = '3',
  $node_name               = $::fqdn,
  $snapshot                = false,
  $verbose                 = false,
  $very_verbose            = false,
  $peer_election_timeout   = '200',
  $peer_heartbeat_interval = '50',
  $peer_addr               = "${::fqdn}:7001",
  $peer_bind_addr          = $peer_addr,
  $peer_ca_file            = '',
  $peer_cert_File          = '',
  $peer_key_file           = '',
) inherits etcd::params {

  validate_array($cors)
  if (!$discovery) {
    validate_array($peers)
  }
  validate_bool($use_upstart)
  validate_bool($manage_user)
  validate_bool($snapshot)
  validate_bool($verbose)
  validate_bool($very_verbose)
  validate_bool($manage_data_dir)

  anchor { 'etcd::begin': } ->
  class  { '::etcd::install': } ->
  class  { '::etcd::config': } ~>
  class  { '::etcd::service': } ->
  anchor { 'etcd::end': }

}
