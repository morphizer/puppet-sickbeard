# == Class: sickbeard
#
# Full description of class sickbeard here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if it
#   has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should not be used in preference to class parameters  as of
#   Puppet 2.6.)
#
# === Examples
#
#  class { sickbeard:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ]
#  }
#
# === Authors
#
# Andrew Harley <morphizer@gmail.com>
#
class sickbeard {

  # Install required  dependencies
  $dependencies = [ 'python', 'python-cheetah', 'git' ]

  pacakge { $dependencies:
    ensure => installed,
  }

  # Create a user to run sickbeard as
  user { 'sickbeard':
    ensure     => present,
    comment    => 'SickBeard user, created by Puppet',
    system     => true,
    managehome => true,
  }

  # Clone the sickbeard source using vcsrepo
  vcsrepo { '/opt/sickbeard':
    ensure   => present,
    provider => git,
    source   => 'git://github.com/midgetspy/Sick-Beard.git'
    owner    => 'sickbeard',
    group    => 'sickbeard',
  }
}
