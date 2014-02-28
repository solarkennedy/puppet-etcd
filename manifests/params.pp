class etcd::params {

  case $::osfamily {
    'Debian','Redhat': {}
    default: { fail("Unsupported osfamily ${::osfamily}") }
  }

  if $::operatingsystem == 'ubuntu' {
    $upstart = present
  }
  else {
    $upstart = absent
  }
  
}
