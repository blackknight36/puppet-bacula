# == Class: bacula::director::postgresql
#
# Manage postgresql resources for the Bacula director.
#
# === Parameters
#
# All <tt>bacula+ classes are called from the main <tt>::bacula</tt> class.  Parameters
# are documented there.
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

class bacula::director::postgresql (
  String $db_database  = 'bacula',
  String $db_host      = 'localhost',
  String $db_password  = extlib::cache_data('bacula', 'db_password', extlib::random_password(32)),
  String $db_port      = '5432',
  String $db_user      = 'bacula',
  String $db_user_host = 'localhost',
  String $db_package   = 'bacula-director-postgresql',
  Boolean $manage_db   = true,
  ) {

  package { $db_package:
    ensure => installed,
  }

  if $manage_db {
    include 'postgresql::server'

    postgresql::server::role { $db_user:
      password_hash => postgresql_password($db_user, $db_password),
    }

    postgresql::server::db { $db_database:
        user     => $db_user,
        password => postgresql_password($db_user, $db_password),
    }
  }

  $make_db_tables_command = $::operatingsystem ? {
    /(Ubuntu|Debian)/ => '/usr/lib/bacula/make_bacula_tables',
    default           => '/usr/libexec/bacula/make_postgresql_tables',
  }

  exec { 'make_db_tables':
    command     => "${make_db_tables_command}",
    user        => 'postgres',
    refreshonly => true,
    logoutput   => true,
    require     => Postgresql::Server::Db['bacula'],
  }
}
