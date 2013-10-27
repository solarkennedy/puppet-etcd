class etcd::install {

  package { 'etcd':
    ensure => $::etcd::package_ensure,
  }
  
  file { $::etcd::storage_dir:
    ensure => 'directory',
    owner  => $::etcd::owner,
    group  => 'root',
    mode   => '0750',
  }

}
