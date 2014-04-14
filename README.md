About
------
[![Build Status](https://travis-ci.org/solarkennedy/puppet-etcd.png)](https://travis-ci.org/solarkennedy/puppet-etcd)

This puppet module installs and configures etcd.

WARNING: This module probably has some rough edges. PR me with your 
modifications! (And tests!)

It is designed around the current version of etcd (at time of this writing), 
0.3.0. 

Examples
---------
Simplest invocation, installs etcd via packages, manages a user, puts data in 
`/var/lib/etcd/` and makes sure it runs on localhost:

    class { 'etcd': }

Parameters
----------
This module is in flux. See init.pp for all parameters and their defaults.

Upstart
---------
Etcd doesn't really include an init script, so this provides a basic one for
for upstart-enabled distros. Pull requests welcome to improve this.

Requirements
-----------
It assumes you have a package available called etcd. If you don't have one
[go make one](https://github.com/solarkennedy/etcd-packages)

Contact
-------
Kyle Anderson <kyle@xkyle.com>

Support
-------
Please log tickets and issues on [GitHub](https://github.com/solarkennedy/puppet-etcd/issues)
