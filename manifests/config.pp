class etcd::config inherits etcd {

  validate_array($cluster_members)

  $cluster_list = join($cluster_members, ',')

  file { '/etc/init/etcd.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0444',
    content => template('etcd/etcd.conf.erb'),
  }

}
