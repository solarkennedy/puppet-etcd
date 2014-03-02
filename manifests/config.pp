class etcd::config inherits etcd {

  file { '/etc/sysconfig/etcd':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('etcd/etcd.sysconfig.erb'),
  }

}
