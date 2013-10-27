class etcd::config {

  file { '/etc/init/etcd.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('etcd/etcd.conf.erb'),
  }

}
