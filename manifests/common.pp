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

  package { $packages:
    ensure => installed,
  }

  if $facts['operatingsystem'] =~ /(?i:opensuse)/ {
    $dist_name = regsubst($facts['lsbdistdescription'], ' ', '_', 'G')
    $baseurl = "http://download.opensuse.org/repositories/home:/Ximi1970:/openSUSE:/Extra/${dist_name}"

    zypprepo { 'home_Ximi1970_openSUSE_Extra':
      baseurl      => $baseurl,
      enabled      => 1,
      autorefresh  => 1,
      name         => 'home_Ximi1970_openSUSE_Extra',
      gpgcheck     => 1,
      gpgkey       => "${baseurl}/repodata/repomd.xml.key",
      priority     => 99,
      keeppackages => 1,
      type         => 'rpm-md',
    }
  }

  if $facts['operatingsystem'] == 'SLES' {
    $baseurl = 'http://download.opensuse.org/repositories/home:/dschossig/SLE_12_SP3'

    zypprepo { 'home_dschossig_SLE_12_SP3':
      baseurl      => $baseurl,
      enabled      => 1,
      autorefresh  => 1,
      name         => 'home:dschossig (SLE_12_SP3)',
      gpgcheck     => 1,
      gpgkey       => "${baseurl}/repodata/repomd.xml.key",
      priority     => 99,
      keeppackages => 1,
      type         => 'rpm-md',
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
            default   => 'root',
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

    # To avoid SELinux denials this directory must belong to the root group.
    # See https://danwalsh.livejournal.com/69478.html for more details on
    # the root cause of this failure
    $lib_dir:
        mode    => '0775',
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
