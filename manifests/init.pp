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
  $service_ensure  = running,
  $service_enable  = true,
  $package_ensure  = installed,
  $use_ssl         = true,
  $client_cert     = "/var/lib/puppet/ssl/certs/${::certname}.pem",
  $client_key      = "/var/lib/puppet/ssl/private_keys/${::certname}.pem",
  $node_name       = $::fqdn,
  $user            = 'puppet',
  $storage_dir     = '/var/lib/etcd/',
  $cluster_members = [],
) inherits etcd::params {

  anchor { 'etcd::begin': } ->
  class  { '::etcd::install': } ->
  class  { '::etcd::config': } ~>
  class  { '::etcd::service': } ->
  anchor { 'etcd::end': }

}
