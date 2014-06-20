# == Class etcd::config
#
class etcd::config {
  case $::osfamily {
    'RedHat' : {
      file { '/etc/sysconfig/etcd':
        ensure  => present,
        owner   => $etcd::user,
        group   => $etcd::group,
        mode    => '0644',
        content => template('etcd/etcd.sysconfig.erb'),
      }
    }
    'Debian' : {
      file { '/etc/etcd':
        ensure => directory,
        owner  => $etcd::user,
        group  => $etcd::group,
        mode   => '0555'
      }

      file { '/etc/etcd/etcd.conf':
        ensure  => file,
        owner   => $etcd::user,
        group   => $etcd::group,
        mode    => '0644',
        content => template('etcd/etcd.conf.erb'),
        require => File['/etc/etcd']
      }
    }
    default  : {
      fail("OSFamily ${::osfamily} not supported.")
    }
  }
}
