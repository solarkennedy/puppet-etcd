class etcd::service inherits etcd {

  if $use_upstart {
    service { 'etcd':
      ensure   => $service_ensure,
      enable   => $service_enable,
      provider => 'upstart',
    }
  } else {
    service { 'etcd':
      ensure   => $service_ensure,
      enable   => $service_enable,
    }
  }

}
