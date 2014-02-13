class etcd::config inherits etcd {

  file { '/etc/etcd/etcd.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('etcd/etcd.conf.erb'),
  }

  file { '/etc/init/etcd.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('etcd/etcd.upstart.erb'),
  }

}
