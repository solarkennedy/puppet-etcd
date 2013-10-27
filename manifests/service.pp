class etcd::service {

  service { 'etcd':
    ensure => $::etcd::service_ensure,
    enable => $::etcd::service_enable,
    provider => 'upstart',
  }

}
