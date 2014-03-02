class etcd::params {

  case $::osfamily {
    'Debian','Redhat': {}
    default: { fail("Unsupported osfamily ${::osfamily}") }
  }

}
