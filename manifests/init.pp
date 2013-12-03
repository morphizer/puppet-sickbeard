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
# [*use_daemon*]
#   Whether or not to start sickbeard as a daemon
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
  $port = '8081',
  $login_user = '',
  $login_pass = '',
  $use_daemon = true,
  $data_dir = undef
) {

  # Install required  dependencies. Doing it this way to get around conflicts
  # from other modules...
  if ! defined(Package['git'])  {
    package { 'git':
      ensure => installed,
    }
  }

  if ! defined(Package['python'])  {
    package { 'python':
      ensure => installed,
    }
  }

  if ! defined(Package['python-cheetah'])  {
    package { 'python-cheetah':
      ensure => installed,
    }
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
    content => $use_daemon ? {
      true => template('sickbeard/init.ubuntu.erb'),
      false => template('sickbeard/ubuntu-init-sickbeard.erb') },
    mode    => '0755',
    require => Vcsrepo[$install_dir],
    notify  => Service["sickbeard"]
  }

  if $use_daemon {
    file { '/etc/default/sickbeard':
      content => template('sickbeard/default.sickbeard.erb')
    }
  }

  service {'sickbeard':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => $use_daemon,
    require    => File['/etc/init.d/sickbeard'],
  }

}
