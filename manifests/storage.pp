# == Class: bacula::storage
#
# This class manages the bacula storage daemon (bacula-sd)
#
# === Parameters
#
# All <tt>bacula+ classes are called from the main <tt>bacula</tt> class.  Parameters
# are documented there.
#
# === Actions:
# * Enforce the DB component package package be installed
# * Manage the <tt>/etc/bacula/bacula-sd.conf</tt> file
# * Manage the <tt>${storage_default_mount}+ and <tt>${storage_default_mount}/default</tt> directories
# * Manage the <tt>/etc/bacula/bacula-sd.conf</tt> file
# * Enforce the <tt>bacula-sd</tt> service to be running
#
# === Copyright
#
# Copyright 2020 Michael Watters
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

class bacula::storage (
  String $console_password              = extlib::cache_data('bacula', 'console_password', extlib::random_password(32)),
  String $db_backend                    = 'sqlite',
  String $director_password             = extlib::cache_data('bacula', 'director_password', extlib::random_password(32)),
  String $director_server               = $facts['fqdn'],
  String $var_dir                       = '/var/lib/bacula',
  String $pid_dir                       = $var_dir,
  Optional[String] $plugin_dir          = '/usr/lib64/bacula',
  String $working_dir                   = $var_dir,
  String $storage_default_mount         = '/mnt/bacula',
  String $storage_server                = $director_server,
  String $storage_package               = 'bacula-storage',
  String $storage_template              = 'bacula/bacula-sd.conf.erb',
  Array[String] $tls_allowed_cn         = [],
  String $tls_ca_cert                   = '/var/lib/bacula/ssl/certs/ca.pem',
  Optional[String] $tls_ca_cert_dir     = undef,
  String $tls_cert                       = "/var/lib/bacula/ssl/certs/${::fqdn}.pem",
  String $tls_key                        = "/var/lib/bacula/ssl/private_keys/${::fqdn}.pem",
  Boolean $tls_require                  = true,
  Boolean $tls_verify_peer              = true,
  Boolean $use_tls                      = true,
  Boolean $block_checksum               = true,
  Hash $storage_device_hash_default     = { 'DefaultFileStorage' => {
    'Media Type'       => 'File',
    'Archive Device'   => "$storage_default_mount/default",
    'Label Media'      => yes,
    'Random Access'    => yes,
    'Automatic Mount'  => yes,
    'Removable Media ' => no,
    'Always Open'      => no,
    'Block Checksum'   => $block_checksum ? {
      default => 'yes',
      false   => 'no',
    },
  },},
  Hash $storage_device_hash             = {},
  Array $storage_hash                   = [],
  Boolean $use_puppet_certs             = true,
  ) {

  include 'bacula::common'

  if $use_puppet_certs {
    include 'bacula::ssl::puppet'
  }

  $_storage_device_hash = $storage_device_hash_default + $storage_device_hash
  package { $storage_package:
    ensure => installed,
  }

  file { $storage_default_mount:
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0755',
    seltype => 'bacula_store_t',
    require => Package[$storage_package],
  }
  # create directories defined as Archive Device in the storage_device_hash
  $_storage_device_hash.each |$name,$data| {
    $data.filter |$key,$value| { $key == 'Archive Device' }.each |$key,$value| {
      ensure_resource('file',$value,{
        ensure  => directory,
        owner   => 'bacula',
        group   => 'bacula',
        mode    => '0755',
        seltype => 'bacula_store_t',
        require => [Package[$storage_package],File[$storage_default_mount]],
      })
    }
  }
  if $storage_hash {
    $storage_hash.each |$arr| {
      $arr.each |$res,$cont| {
        $cont.each |$name,$data| {
          $data.filter |$key,$value| { $key == 'Archive Device' }.each |$key,$value| {
            ensure_resource('file',$value,{
              ensure  => directory,
              owner   => 'bacula',
              group   => 'bacula',
              mode    => '0755',
              seltype => 'bacula_store_t',
              require => [Package[$storage_package],File[$storage_default_mount]],
            })
          }
        }
      }
    }
  }
  if $facts['osfamily'] == 'RedHat' and $facts['selinux'] {
    selinux::fcontext { "${storage_default_mount}(/.*)?":
      seltype => 'bacula_store_t',
    }
  }

  file { '/etc/bacula/bacula-sd.d':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0750',
    require => Package[$storage_package],
  }

  file { '/etc/bacula/bacula-sd.d/empty.conf':
    ensure => file,
    owner  => 'bacula',
    group  => 'bacula',
    mode   => '0640',
  }

  $file_requires = $plugin_dir ? {
    undef   => File[
      '/etc/bacula/bacula-sd.d/empty.conf',
      "${storage_default_mount}/default",
      '/var/lib/bacula'
    ],
    default => File[
      '/etc/bacula/bacula-sd.d/empty.conf',
      "${storage_default_mount}/default",
      '/var/lib/bacula',
      $plugin_dir
    ],
  }

  file { '/etc/bacula/bacula-sd.conf':
    ensure    => file,
    owner     => 'bacula',
    group     => 'bacula',
    mode      => '0640',
    content   => template($storage_template),
    require   => $file_requires,
    notify    => Service['bacula-sd'],
  }

  # Register the Service so we can manage it through Puppet
  service { 'bacula-sd':
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
  }
}
