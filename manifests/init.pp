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
# Mathew Finch <finchster@gmail.com>
# Gavin Williams <fatmcgav@gmail.com>
#
class etcd (
  $service_ensure          = $etcd::params::etcd_service_ensure,
  $service_enable          = $etcd::params::etcd_service_enable,
  $package_ensure          = $etcd::params::etcd_package_ensure,
  $package_name            = $etcd::params::etcd_package_name,
  $binary_location         = $etcd::params::etcd_binary_location,
  $manage_user             = $etcd::params::etcd_manage_user,
  $user                    = $etcd::params::etcd_user,
  $group                   = $etcd::params::etcd_group,
  $addr                    = $etcd::params::etcd_addr,
  $bind_addr               = $etcd::params::etcd_bind_addr,
  $ca_file                 = $etcd::params::etcd_ca_file,
  $cert_file               = $etcd::params::etcd_cert_file,
  $key_file                = $etcd::params::etcd_key_file,
  $cors                    = $etcd::params::etcd_cors,
  $cpu_profile_file        = $etcd::params::etcd_cpu_profile_file,
  $manage_data_dir         = $etcd::params::etcd_manage_data_dir,
  $data_dir                = $etcd::params::etcd_data_dir,
  $discovery               = $etcd::params::etcd_discovery,
  $discovery_endpoint      = $etcd::params::etcd_discovery_endpoint,
  $discovery_token         = $etcd::params::etcd_discovery_token,
  $peers                   = $etcd::params::etcd_peers,
  $peers_file              = $etcd::params::etcd_peers_file,
  $max_result_buffer       = $etcd::params::etcd_max_result_buffer,
  $max_retry_attempts      = $etcd::params::etcd_max_retry_attempts,
  $node_name               = $etcd::params::etcd_node_name,
  $snapshot                = $etcd::params::etcd_snapshot,
  $snapshot_count          = $etcd::params::etcd_snapshot_count,
  $verbose                 = $etcd::params::etcd_verbose,
  $very_verbose            = $etcd::params::etcd_very_verbose,
  $peer_election_timeout   = $etcd::params::etcd_peer_election_timeout,
  $peer_heartbeat_interval = $etcd::params::etcd_peer_heartbeat_interval,
  $peer_addr               = $etcd::params::etcd_peer_addr,
  $peer_bind_addr          = $etcd::params::etcd_peer_bind_addr,
  $peer_ca_file            = $etcd::params::etcd_peer_ca_file,
  $peer_cert_File          = $etcd::params::etcd_peer_cert_File,
  $peer_key_file           = $etcd::params::etcd_peer_key_file) inherits etcd::params {
  validate_array($cors)

  if (!$discovery) {
    validate_array($peers)
  }
  validate_bool($manage_user)
  validate_bool($snapshot)
  validate_bool($verbose)
  validate_bool($very_verbose)
  validate_bool($manage_data_dir)

  anchor { 'etcd::begin': } ->
  class { '::etcd::install': } ->
  class { '::etcd::config': } ~>
  class { '::etcd::service': } ->
  anchor { 'etcd::end': }

}
