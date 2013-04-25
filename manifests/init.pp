# == Class: sickbeard
#
# Installs and configures sickbeard.
#
# === Parameters
#
# [*install_dir*]
#   Where sickbeard should be installed to. Default: /opt/sickbeard
#
# [*user*]
#   The user to run sickbeard service as. Default: sickbeard
#
# === Examples
#
# include sickbeard
#
# === Authors
#
# Andrew Harley <morphizer@gmail.com>
#
class sickbeard (
  $install_dir = '/opt/sickbeard',
  $user = 'sickbeard',
  $address = '0.0.0.0',
  $port = '8180',
  $login_user = '',
  $login_pass = '',
) {

  # Install required  dependencies
  $dependencies = [ 'python', 'python-cheetah', 'git' ]

  package { $dependencies:
    ensure => installed,
  }

  # Create a user to run sickbeard as
  user { $user:
    ensure     => present,
    comment    => 'SickBeard user, created by Puppet',
    system     => true,
    managehome => true,
  }

  # Clone the sickbeard source using vcsrepo
  vcsrepo { $install_dir:
    ensure   => present,
    provider => git,
    source   => 'git://github.com/midgetspy/Sick-Beard.git',
    owner    => $user,
    require  => User[$user],
  }

  file { '/etc/init.d/sickbeard':
    ensure  => file,
    content => template('sickbeard/ubuntu-init-sickbeard.erb'),
    mode    => '0755',
    require => Vcsrepo[$install_dir],
  }

  service {'sickbeard':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => false,
    require    => File['/etc/init.d/sickbeard'],
  }

}
