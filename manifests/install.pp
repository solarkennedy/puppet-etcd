class etcd::install {

  package { 'etcd':
    ensure => $etcd::package_ensure,
  }
  
}
