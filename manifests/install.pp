# == Class etcd::install
class etcd::install (
  $url     = $etcd::package_url,
  $version = $etcd::package_version
  ) {
  # Create group and user if required
  if $etcd::manage_user {
    group { $etcd::group: ensure => 'present' }

    user { $etcd::user:
      ensure  => 'present',
      gid     => $etcd::group,
      require => Group[$etcd::group],
      before  => Package['etcd']
    }
  }

  # Create etcd data dir if required
  if $etcd::manage_data_dir {
    file { $etcd::data_dir:
      ensure => 'directory',
      owner  => $etcd::user,
      group  => $etcd::group,
      mode   => '0750',
      before => Package['etcd']
    }
  }

  # Create etcd log dir if required
  if $etcd::manage_log_dir {
    file { $etcd::log_dir:
      ensure => 'directory',
      owner  => $etcd::user,
      group  => $etcd::group,
      mode   => '0750',
      before => Package['etcd']
    }
  }

  # Setup resource ordering if appropriate
  if ($etcd::manage_user and $etcd::manage_data_dir) {
    User[$etcd::user] -> File[$etcd::data_dir]
  }
  if ($etcd::manage_user and $etcd::manage_log_dir) {
    User[$etcd::user] -> File[$etcd::log_dir]
  }

  # Install the required package
  if $url != undef {
    exec {
      'download-etcd':
        command => "curl -O ${url}/etcd_${version}_${::architecture}.deb 2> /dev/null",
        path    => ['/usr/bin', '/bin', '/usr/local/bin'],
        cwd     => '/usr/src',
        creates => "/usr/src/etcd_${version}_${::architecture}.deb",
        before  => Package['etcd']
    }

    package { 'etcd':
      ensure   => $etcd::package_ensure,
      name     => $etcd::package_name,
      source   => "/usr/src/etcd_${version}_${::architecture}.deb",
      provider => 'dpkg'
    }
  }
  else {
    package {
      'etcd':
        ensure => $etcd::package_ensure,
        name   => $etcd::package_name
    }
  }
}
