# == Class: bacula::common
#
# This class enforces common resources needed by all bacula components
#
# === Parameters
#
# All <tt>bacula+ classes are called from the main <tt>::bacula</tt> class.  Parameters
# are documented there.
#
# === Actions:
# * Enforce the bacula user and groups exist
# * Enforce the <tt>/var/spool/bacula+ is a director and <tt>/var/lib/bacula</tt>
#   points to it
#
# === Copyright
#
# Copyright 2019 Michael Watters
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

class bacula::common (
  Boolean $manage_config_dir = false,
  Boolean $manage_db_tables  = true,
  String  $conf_dir          = '/etc/bacula',
  String  $lib_dir           = '/var/lib/bacula',
  String  $log_dir           = '/var/log/bacula',
  String  $plugin_dir        = '/usr/lib64/bacula',
  String  $spool_dir         = '/var/spool/bacula',
  Array[String] $packages    = ['bacula-common'],
  ) {

  # FreeBSD does not have a "common" package
  if $facts['operatingsystem'] != 'FreeBSD' {
    package { $packages:
      ensure => installed,
    }

    # To avoid SELinux denials this directory must belong to the root group.
    # See https://danwalsh.livejournal.com/69478.html for more details on
    # the root cause of this failure
    file { $lib_dir:
        ensure  => 'directory',
        owner   => 'bacula',
        group   => 'root',
        mode    => '0775',
    }
  }

  $config_dir_source = $manage_config_dir ? {
    true    => 'puppet:///modules/bacula/bacula-empty.dir',
    default => undef,
  }

  file {
    default:
        ensure => directory,
        owner  => $facts['kernel'] ? {
            'windows' => 'BUILTIN\Administrators',
            default   => 'bacula',
        },
        group  => $facts['kernel'] ? {
            'windows' => 'Internet User',
            default   => 'bacula',
        },
        require => $facts['kernel'] ? {
            'FreeBSD' => undef,
            'windows' => undef,
            default   => Package[$packages],
        },
    ;

    $plugin_dir:
        owner  => $facts['kernel'] ? {
            'windows' => 'BUILTIN\Administrators',
            default   => 'root',
        },
        group  => $facts['kernel'] ? {
            'windows' => 'Internet User',
            default   => 0,
        },
        mode   => $facts['kernel'] ? {
            'windows' => undef,
            default   => '0755',
        },
    ;

    $conf_dir:
        mode => $facts['kernel'] ? {
            'windows' => undef,
            default   => '0750',
        },
        purge   => $manage_config_dir,
        force   => $manage_config_dir,
        recurse => $manage_config_dir,
        source  => $config_dir_source,
    ;

    # This is necessary to prevent the object above from deleting the supplied scripts
    "${conf_dir}/scripts":
    ;

    $spool_dir:
        mode    => '0755',
    ;

    $log_dir:
        recurse => true,
        mode    => '0755',
    ;
  }
}
