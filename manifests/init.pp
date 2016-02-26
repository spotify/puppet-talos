# == Class: Talos
#
# Manage Talos, hiera secrets distribution tool.
#
# == Parameters
#
# [*configure_repo*]
#   Sets up a git repository for hiera secrets.
#   You can specify authorized_keys_source or
#   authorized_keys_content to set it up as a destination for git replication.
#   Boolean, default is true
#
# [*configure_apache*]
#   Sets up an apache server with mod_passenger to run Talos rack application
#   Boolean, default is true
#

class talos (
  $hiera_yaml_content      = undef,
  $hiera_yaml_source       = undef,
  $talos_yaml_content      = undef,
  $talos_yaml_source       = undef,
  $authorized_keys_source  = undef,
  $authorized_keys_content = undef,
  $user                    = 'talos',
  $group                   = 'talos',
  $homedir                 = '/var/lib/talos',
  $certfile                = "${::settings::ssldir}/certs/${::fqdn}.pem",
  $keyfile                 = "${::settings::ssldir}/private_keys/${::fqdn}.pem",
  $cafile                  = "${::settings::ssldir}/certs/ca.pem",
  $crlfile                 = "${::settings::ssldir}/crl.pem",
  $chainfile               = "${::settings::ssldir}/certs/ca.pem",
  $configure_repo          = true,
  $configure_apache        = true,
  $talos_package_ensure    = 'present',
  $talos_package_provider  = 'gem',
) {

  package { 'talos':
    ensure   => $talos_package_ensure,
    provider => $talos_package_provider,
  }

  file { $homedir:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  user { $user:
    system => true,
    home   => $homedir,
    gid    => $group,
  }

  group { $group:
    ensure => present,
  }

  file { "${homedir}/config.ru":
    owner   => $user,
    group   => $user,
    content => "require 'rubygems'\nrequire 'talos'\nrun Talos",
  }

  file { ["${homedir}/public", "${homedir}/tmp"]:
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  file { '/etc/talos':
    ensure => directory,
    owner  => $user,
    group  => $group,
  }

  file { '/etc/talos/hiera.yaml':
    owner   => $user,
    group   => $group,
    source  => $hiera_yaml_source,
    content => $hiera_yaml_content,
  }

  file { '/etc/talos/talos.yaml':
    owner   => $user,
    group   => $group,
    source  => $talos_yaml_source,
    content => $talos_yaml_content,
  }

  if $configure_repo {
    $incoming_secrets   = "${homedir}/secrets.git"
    $checkout_directory = "${homedir}/checked_out_secrets"

    file { "${homedir}/.ssh":
      ensure => directory,
      owner  => $user,
      mode   => '0700',
    }

    file { "${homedir}/.ssh/authorized_keys":
      owner   => $user,
      mode    => '0600',
      content => $authorized_keys_content,
      source  => $authorized_keys_source,
    }

    file { $checkout_directory:
      ensure => directory,
      owner  => $user,
      group  => $group,
      mode   => '0750',
    }

    vcsrepo { $incoming_secrets:
      ensure   => 'bare',
      owner    => $user,
      group    => $group,
      provider => 'git',
      require  => User[$user],
    }

    file { "${incoming_secrets}/hooks/update":
      ensure  => file,
      content => template('talos/git-update-hook.erb'),
      owner   => $user,
      group   => $group,
      mode    => '0755',
      require => Vcsrepo[$incoming_secrets],
    }
  }

  if $configure_apache {
    include apache
    include apache::mod::passenger
    include apache::mod::headers
    include apache::mod::ssl

    Package['talos'] {
      notify => Service['apache2'],
    }

    apache::vhost { $user:
      servername        => $::fqdn,
      port              => 8141,
      docroot           => "${homedir}/public",
      ssl               => true,
      ssl_ca            => $cafile,
      ssl_chain         => $cafile,
      ssl_cert          => $certfile,
      ssl_key           => $keyfile,
      ssl_crl           => $crlfile,
      ssl_verify_client => 'require',
      ssl_options       => ['+StdEnvVars', '+FakeBasicAuth'],
      request_headers   => ['set SSL_CLIENT_S_DN_CN "%{SSL_CLIENT_S_DN_CN}s"'],
      require           => Package['talos'],
    }
  }
}
