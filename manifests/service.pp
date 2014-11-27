# == Class etcd::service
#
class etcd::service {
  # Switch service details based on osfamily
  case $::osfamily {
    'RedHat' : {
      $service_file_location = '/etc/init.d/etcd'
      $service_file_contents = template('etcd/etcd.initd.erb')
      $service_file_mode     = '0755'
      $service_provider      = undef
    }
    'Debian' : {
      $service_file_location = '/etc/init/etcd.conf'
      $service_file_contents = template('etcd/etcd.upstart.erb')
      $service_file_mode     = '0444'
      $service_provider      = 'upstart'
    }
    default  : {
      fail("OSFamily ${::osfamily} not supported.")
    }

  }

  # Create the appropriate service file
  if $etcd::manage_service_file {
    file { 'etcd-servicefile':
      ensure  => file,
      path    => $service_file_location,
      owner   => $etcd::user,
      group   => $etcd::group,
      mode    => $service_file_mode,
      content => $service_file_contents,
      notify  => Service['etcd']
    }
  }

  # Set service status
  service { 'etcd':
    ensure   => $etcd::service_ensure,
    enable   => $etcd::service_enable,
    provider => $service_provider,
  }
}
