class etcd::service inherits etcd {

  service { 'etcd':
    ensure   => $service_ensure,
    enable   => $service_enable,
  }

}
