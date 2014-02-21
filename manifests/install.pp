class etcd::install inherits etcd {

  package { 'etcd':
    name   => $package_name,
    ensure => $package_ensure,
  }
  
  if $manage_data_dir {
    file { $data_dir:
      ensure  => 'directory',
      owner   => $user,
      group   => 'root',
      mode    => '0750',
      recurse => true
    }
  }

  if $manage_user {
    user { $user:
      ensure => 'present',
    }
  }

}
