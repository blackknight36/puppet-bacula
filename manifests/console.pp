# == Class: bacula::console
#
# This class manages the bconsole application
#
# === Parameters
#
# All <tt>bacula+ classes are called from the main <tt>::bacula</tt> class.  Parameters
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

class bacula::console (
  String $console_template          = 'bacula/bconsole.conf.erb',
  String $director_password         = extlib::cache_data('bacula', 'director_password', extlib::random_password(32)),
  String $director_server           = $facts['fqdn'],
  String $tls_ca_cert               = '/var/lib/bacula/ssl/certs/ca.pem',
  Optional[String] $tls_ca_cert_dir = undef,
  String $tls_cert                  = "/var/lib/bacula/ssl/certs/${::fqdn}.pem",
  String $tls_key                   = "/var/lib/bacula/ssl/private_keys/${::fqdn}.pem",
  Boolean $tls_require              = true,
  Boolean $tls_verify_peer          = true,
  Boolean $use_tls                  = true,
  String $package                   = 'bacula-console',
  ) {

  package { $package:
    ensure => present,
  }

  file { '/etc/bacula/bconsole.conf':
    ensure    => file,
    owner     => 'bacula',
    group     => 'bacula',
    mode      => '0640',
    content   => template($console_template),
    require   => Package[$package],
    show_diff => false,
  }

  # Instead of restarting the <code>bacula-dir</code> service which could interrupt running jobs tell the director to reload its
  # configuration.
  exec { 'bacula-dir reload':
    command     => '/bin/echo reload | /usr/sbin/bconsole',
    logoutput   => on_failure,
    refreshonly => true,
    timeout     => 10,
    require     => Package[$package],
  }
}
