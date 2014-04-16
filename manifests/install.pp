# == Class etcd::install
#
class etcd::install {

  package { 'etcd':
    ensure => $etcd::package_ensure,
    name   => $etcd::package_name,
  }

  if $etcd::manage_data_dir {
    file { $etcd::data_dir:
      ensure => 'directory',
      owner  => $etcd::user,
      group  => 'root',
      mode   => '0750',
    }
  }

  if $etcd::manage_user {
    user { $etcd::user:
      ensure => 'present',
    }
  }

}
