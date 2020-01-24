# == Class: bacula::director
#
# This class manages the Bacula director component
#
# === Parameters
#
# All <tt>bacula</tt> classes are called from the main <tt>bacula</tt> class.  Parameters
# are documented there.
#
# === Copyright
#
# Copyright 2018 Michael Watters
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

class bacula::director (
  Boolean $backup_catalog                   = true,
  Optional[Hash] $clients                   = undef,
  String $console_password                  = cache_data('bacula', 'console_password', extlib::random_password(32)),
  String $db_backend                        = 'sqlite',
  String $db_database                       = 'bacula',
  String $db_host                           = 'localhost',
  String $db_password                       = cache_data('bacula', 'db_password', extlib::random_password(32)),
  Optional[String] $db_port                 = undef,
  String $db_user                           = 'bacula',
  Optional[String] $db_user_host            = undef,
  String $dir_template                      = 'bacula/bacula-dir.conf.erb',
  String $director_package                  = 'bacula-director',
  String $director_password                 = cache_data('bacula', 'director_password', extlib::random_password(32)),
  String $director_server                   = $facts['fqdn'],
  String $director_service                  = 'bacula-dir',
  String $mail_command                      = "/usr/sbin/bsmtp -h localhost -f bacula@${::fqdn} -s \\\"Bacula %t %e (for %c)\\\" %r",
  Optional[String] $mail_to                 = undef,
  Optional[String] $mail_to_daemon          = undef,
  Optional[String] $mail_to_on_error        = undef,
  Optional[String] $mail_to_operator        = undef,
  Boolean $manage_config_dir                = false,
  Boolean $manage_db                        = true,
  Boolean $manage_db_tables                 = true,
  Optional[Boolean] $manage_logwatch        = undef,
  String $operator_command                  = "/usr/sbin/bsmtp -h localhost -f bacula@${::fqdn} -s \\\"Bacula Intervention Required (for %c)\\\" %r",
  Optional[String] $plugin_dir              = '/usr/lib64/bacula',
  String $storage_server                    = "bacula.${facts['domain']}",
  Array[String] $tls_allowed_cn             = [],
  Optional[String] $tls_ca_cert             = undef,
  Optional[String] $tls_ca_cert_dir         = undef,
  Optional[String] $tls_cert                = undef,
  Optional[String] $tls_key                 = undef,
  Boolean $tls_require                      = true,
  Boolean $tls_verify_peer                  = true,
  Boolean $use_tls                          = false,
  Boolean $use_vol_purge_script             = false,
  Optional[Boolean] $use_vol_purge_mvdir    = undef,
  Boolean $volume_autoprune                 = true,
  Boolean $volume_autoprune_diff            = true,
  Boolean $volume_autoprune_full            = true,
  Boolean $volume_autoprune_incr            = true,
  String $volume_max_bytes                  = '10G',
  String $volume_max_volumes                = '2000',
  String $volume_retention                  = '1 Year',
  String $volume_retention_diff             = '40 Days',
  String $volume_retention_full             = '1 Year',
  String $volume_retention_incr             = '10 Days',
  String $storage_default_mount             = '/mnt/bacula',
  String $var_dir                           = '/var/lib/bacula',
  ) {

  include 'bacula::common'
  include 'bacula::console'

  package { $director_package:
    ensure => installed,
  }

  if $clients {
    # This function takes each client specified in <tt>$clients</tt>
    # and generates a <tt>bacula::client</tt> resource for each
    create_resources('bacula::client::config', $clients)
  }

  file { '/etc/bacula/bacula-dir.d/empty.conf':
    ensure  => file,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0640',
    content => '',
  }

  $config_dir_source = $manage_config_dir ? {
    true    => 'puppet:///modules/bacula/bacula-empty.dir',
    default => undef,
  }

  # Create the configuration for the Director and make sure the directory for
  # the per-Client configuration is created before we run the realization for
  # the exported files below
  file { '/etc/bacula/bacula-dir.d':
    ensure  => directory,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0750',
    purge   => $manage_config_dir,
    force   => $manage_config_dir,
    recurse => $manage_config_dir,
    source  => $config_dir_source,
    notify  => Exec['bacula-dir reload'],
    require => Package[$director_package],
  }

  if defined('$plugin_dir') {
    $file_requires = File[
      '/etc/bacula/bacula-dir.d',
      '/etc/bacula/bacula-dir.d/empty.conf',
      '/var/lib/bacula',
      '/var/log/bacula',
      '/var/spool/bacula',
      $plugin_dir]
  }

  else {
    $file_requires = File[
      '/etc/bacula/bacula-dir.d',
      '/etc/bacula/bacula-dir.d/empty.conf',
      '/var/lib/bacula',
      '/var/log/bacula',
      '/var/spool/bacula']
  }

  $purge_script_ensure = $use_vol_purge_script ? {
    true    => file,
    default => absent,
  }

  file { '/usr/local/bin/bacula-prune-all-volumes.sh':
    ensure  => $purge_script_ensure,
    owner   => 'bacula',
    group   => 'bacula',
    mode    => '0750',
    content => template('bacula/bacula-prune-all-volumes.sh.erb'),
    before  => File['/etc/bacula/bacula-dir.conf'],
  }

  $purge_script_command = $use_vol_purge_mvdir ? {
    undef   => "/usr/local/bin/bacula-prune-all-volumes.sh -s ${storage_default_mount}/default",
    default => "/usr/local/bin/bacula-prune-all-volumes.sh -s ${storage_default_mount}/default -m ${use_vol_purge_mvdir}",
  }

  $db_driver = $db_backend ? {
    'postgresql' => 'PostgreSQL',
    'mysql'      => 'MySQL',
    'sqlite'     => 'dbi:sqlite',
  }

  file { '/etc/bacula/bacula-dir.conf':
    ensure    => file,
    owner     => 'bacula',
    group     => 'bacula',
    mode      => '0640',
    content   => template($dir_template),
    require   => $file_requires,
    before    => Service['bacula-dir'],
    notify    => Exec['bacula-dir reload'],
    show_diff => false,
  }

  if $manage_db or $manage_db_tables {
    case $db_backend {
      'mysql'  : {
        include 'bacula::director::mysql'
        class { 'bacula::director::mysql':
          db_database   => $db_database,
          db_host       => $db_host,
          db_password   => $db_password,
          db_port       => $db_port,
          db_user       => $db_user,
          db_user_host  => $db_user_host,
          db_package    => $db_package,
          manage_db     => $manage_db,
        }
      }

      'postgresql' : {
        include 'bacula::director::postgresql'
      }

      'sqlite' : {
        include 'bacula::director::sqlite'
      }

      default  : {
        fail "The bacula module does not support the ${db_backend} database backend."
      }
    }
  }

  # Register the Service so we can manage it through Puppet
  if $manage_db_tables {
    $service_require = [
      Exec['make_db_tables'],
      File['/etc/bacula/bacula-dir.conf'],
    ]
  } else {
    $service_require = File['/etc/bacula/bacula-dir.conf']
  }

  service { 'bacula-dir':
    ensure     => running,
    name       => $director_service,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => $service_require,
  }
}
