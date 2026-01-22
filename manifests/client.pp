# == Class: bacula::client
#
# This class manages the bacula client (bacula-fd)
#
# === Parameters
#
# [*var_dir*]
#   Path to the bacula state directory.
#
# [*bacula_fd_conf*]
#   Path to the bacula file daemon config file.
#
# [*client_package*]
#   Name of the bacula client package.
#
# [*director_password*]
#   The director's password.  By default this will be randomly generated on the puppet master.
#
# [*director_server*]
#   The FQDN of the bacula director.  Default value is bacula.$domain
#
# [*plugin_dir*]
#   The directory Bacula plugins are stored in. Use this parameter if you are providing Bacula plugins for use. Only use if the package in the distro repositories supports plugins or you have included a respository with a newer Bacula packaged for your distro. If this is anything other than `undef` and you are not providing any plugins in this directory Bacula will throw an error every time it starts even if the package supports plugins.
#
# [*tls_allowed_cn*]
#   Array of common name attribute of allowed peer certificates. If this directive is specified, all server
#   certificates will be verified against this list. This can be used to ensure that only the CA-approved Director
#   may connect.
#
# [*tls_ca_cert*]
#   The full path and filename specifying a PEM encoded TLS CA certificate(s). Multiple certificates are permitted in
#   the file. One of <tt>TLS CA Certificate File</tt> or <tt>TLS CA Certificate Dir</tt> are required in a server context if
#   <tt>TLS Verify Peer</tt> is also specified, and are always required in a client context.
#
# [*tls_ca_cert_dir*]
#   Full path to TLS CA certificate directory. In the current implementation, certificates must be stored PEM
#   encoded with OpenSSL-compatible hashes, which is the subject name's hash and an extension of .0. One of
#   <tt>TLS CA Certificate File</tt> or <tt>TLS CA Certificate Dir</tt> are required in a server context if <tt>TLS Verify Peer</tt>
#   is also specified, and are always required in a client context.
#
# [*tls_cert*]
#   The full path and filename of a PEM encoded TLS certificate. It can be used as either a client or server
#   certificate. PEM stands for Privacy Enhanced Mail, but in this context refers to how the certificates are
#   encoded. It is used because PEM files are base64 encoded and hence ASCII text based rather than binary. They may
#   also contain encrypted information.
#
# [*tls_key*]
#   The full path and filename of a PEM encoded TLS private key. It must correspond to the TLS certificate.
#
# [*tls_require*]
#   Require TLS connections. This directive is ignored unless <tt>TLS Enable</tt> is set to yes. If TLS is not required,
#   and TLS is enabled, then Bacula will connect with other daemons either with or without TLS depending on what the
#   other daemon requests. If TLS is enabled and TLS is required, then Bacula will refuse any connection that does
#   not use TLS. Valid values are <tt>true</tt> or <tt>false</tt>.
#
# [*tls_verify_peer*]
#   Verify peer certificate. Instructs server to request and verify the client's x509 certificate. Any client
#   certificate signed by a known-CA will be accepted unless the <tt>TLS Allowed CN</tt> configuration directive is used, in
#   which case the client certificate must correspond to the Allowed Common Name specified. Valid values are <tt>true</tt>
#   or <tt>false</tt>.
#
# [*use_tls*]
#   Whether to use {Bacula TLS - Communications
#   Encryption}[http://www.bacula.org/en/dev-manual/main/main/Bacula_TLS_Communications.html].
#
# [*pki_encryption*]
#   If set to true encrypt backup on the client with the given keypair
#
# [*manage_pki_keypair*]
#   If true a keypair will be created through puppet on every client, defaults to true
#
# [*pki_keypair*]
#   Path to the client specific TLS keypair which is used to en- and decrypt the backup data
#
# [*pki_master_key*]
#   Public TLS key of the master key to be able to decrypt backup even though the client keypair is lost
#
# [*use_puppet_certs*]
#   Controls use of puppet certificates for bacula authentication.  Default value is true.
#
# === Actions:
# * Enforce the client package package be installed
# * Manage the <tt>/etc/bacula/bacula-fd.conf</tt> file
# * Enforce the <tt>bacula-fd</tt> service to be running
#
# === Copyright
#
# Copyright 2021 Michael Watters
#
# === License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class bacula::client (
  String $bacula_fd_conf            = '/etc/bacula/bacula-fd.conf',
  String $client_package            = 'bacula-client',
  String $director_password         = extlib::cache_data('bacula', 'director_password', extlib::random_password(32)),
  String $director_server           = "bacula.${facts['domain']}",
  String $plugin_dir                = '/usr/lib64/bacula',
  String $var_dir                   = '/var/lib/bacula',
  String $pid_dir                   = $var_dir,
  String $working_dir               = $var_dir,
  Array[String] $tls_allowed_cn     = [],
  String $tls_ca_cert               = "${var_dir}/ssl/certs/ca.pem",
  String $tls_cert                  = "${var_dir}/ssl/certs/${trusted['certname']}.pem",
  String $tls_key                   = "${var_dir}/ssl/private_keys/${trusted['certname']}.pem",
  Optional[String] $tls_ca_cert_dir = undef,
  Boolean $tls_require              = true,
  Boolean $tls_verify_peer          = true,
  Boolean $use_tls                  = true,
  Boolean $pki_encryption           = false,
  Boolean $manage_pki_keypair       = true,
  String $pki_keypair               = "${var_dir}/ssl/encryption_keypair.pem",
  String $pki_master_key            = "${var_dir}/ssl/certs/master.crt",
  Boolean $use_puppet_certs         = true,
  ) {

  include 'bacula::common'

  if $use_puppet_certs {
    include 'bacula::ssl::puppet'
  }

  package { $client_package:
    ensure => installed,
  }

  file { 'bacula-fd.conf':
    ensure    => file,
    path      => $bacula_fd_conf,
    owner     => $facts['os']['name'] ? { windows => 'Administrator', default => 'bacula'},
    group     => $facts['os']['name'] ? { windows => 'Administrators', default => 'bacula'},
    mode      => '0640',
    content   => template('bacula/bacula-fd.conf.erb'),
    require   => Package[$client_package],
    notify    => Service['bacula-fd'],
    show_diff => false,
  }

  if $facts['selinux'] {
    selboolean { 'domain_can_mmap_files':
        value      => 'on',
        persistent => true,
        notify     => Service['bacula-fd'],
        before     => Service['bacula-fd'],
    }

    selinux::module { 'bacula_fd_fix':
      source_te => 'puppet:///modules/bacula/selinux/bacula_fd_fix.te',
      notify    => Service['bacula-fd'],
      before    => Service['bacula-fd'],
    }
  }

  service { 'bacula-fd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => File['bacula-fd.conf'],
  }

  if $pki_encryption and $manage_pki_keypair {

    $pki_keypair_path=dirname("$pki_keypair")
    exec { "create $pki_keypair_path":
      creates => $pki_keypair_path,
      command => "/bin/mkdir -p $pki_keypair_path",
      path    => '/bin:/usr/local/bin:/usr/bin',
      require => Package[$client_package],
      before  => File[$pki_keypair_path],
    }
    file { $pki_keypair_path:
      ensure    => directory,
      owner     => 'bacula',
      group     => 'bacula',
      mode      => '0640',
      require   => Package[$client_package],
    }
    exec { 'create_keypair':
      command     => "openssl genrsa -out /tmp/private.key 4096 && openssl req -new -key /tmp/private.key -x509 -out /tmp/public.crt -subj '/C=XX/ST=unknown/L=puppet-bacula/O=Bacula Backup/OU=backup/CN=${trusted['certname']}' && cat /tmp/private.key /tmp/public.crt >$pki_keypair && chmod 0400 $pki_keypair && rm /tmp/private.key /tmp/public.crt /tmp/.rnd",
      creates     => "$pki_keypair",
      environment => 'RANDFILE=/tmp/.rnd',
      notify      => Service['bacula-fd'],
      path        => '/bin:/usr/local/bin:/usr/bin',
      user        => 'bacula',
      require     => Package[$client_package],
    }
  }

}
