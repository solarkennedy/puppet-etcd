# == Class etcd::params
#
class etcd::params {
  # Handle OS Specific config values
  case $::osfamily {
    'Redhat' : { $etcd_binary_location = '/usr/sbin/etcd' }
    'Debian' : { $etcd_binary_location = '/usr/bin/etcd' }
    default  : { fail("Unsupported osfamily ${::osfamily}") }
  }

  # Service settings
  $etcd_service_ensure          = 'running'
  $etcd_service_enable          = true
  $etcd_manage_service_file     = true

  # Package settings
  $etcd_package_ensure          = 'installed'
  $etcd_package_name            = 'etcd'

  # User settings
  $etcd_manage_user             = true
  $etcd_user                    = 'etcd'
  $etcd_group                   = 'etcd'

  # Manage Data Dir?
  $etcd_manage_data_dir         = true
  $etcd_data_dir                = '/var/lib/etcd'

  # Manage Log Dir?
  $etcd_manage_log_dir          = true
  $etcd_log_dir                 = '/var/log/etcd'

  # Node settings
  $etcd_node_name               = $::fqdn
  $etcd_addr                    = "${::fqdn}:4001"
  $etcd_bind_addr               = $etcd_addr
  $etcd_ca_file                 = ''
  $etcd_cert_file               = ''
  $etcd_key_file                = ''
  $etcd_cors                    = []
  $etcd_cpu_profile_file        = ''

  # Discovery support
  $etcd_discovery               = false
  $etcd_discovery_endpoint      = 'https://discovery.etcd.io/'
  $etcd_discovery_token         = ''

  # Peer settings
  $etcd_peer_addr               = "${::fqdn}:7001"
  $etcd_peer_bind_addr          = $etcd_peer_addr
  $etcd_peers                   = []
  $etcd_peers_file              = undef
  $etcd_peer_ca_file            = ''
  $etcd_peer_cert_File          = ''
  $etcd_peer_key_file           = ''
  $etcd_peer_election_timeout   = '200'
  $etcd_peer_heartbeat_interval = '50'

  # Logging settings
  $etcd_verbose                 = false
  $etcd_very_verbose            = false

  # Snapshot settings
  $etcd_snapshot                = true
  $etcd_snapshot_count          = '10000'

  # Tuning settings
  $etcd_max_result_buffer       = '1024'
  $etcd_max_retry_attempts      = '3'

	# Cluster settings
	$etcd_cluster_active_size          = false
	$etcd_cluster_remove_delay         = '1800.0'
	$etcd_cluster_sync_interval        = '5.0'
}
