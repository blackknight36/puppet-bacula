# == Class: bacula::director::mysql
#
# Manage MySQL resources for the Bacula director.
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

class bacula::director::mysql (
  String $db_database  = 'bacula',
  String $db_host      = 'localhost',
  String $db_password  = cache_data('bacula', 'db_password', extlib::random_password(32)),
  String $db_port      = '3306',
  String $db_user      = 'bacula',
  String $db_user_host = 'localhost',
  String $db_package   = 'bacula-storage-mysql',
  Boolean $manage_db   = true,
  ) {

  package { $db_package:
    ensure => present,
  }

  #FIXME Due to a bug in v1.0.0 of the puppetlabs-mysql module I can't use a notify here on the define.
  if $manage_db {
    include 'mysql::server'

    mysql::db { $db_database:
      ensure   => present,
      user     => $db_user,
      password => $db_password,
      host     => $db_user_host,
      grant    => ['ALL'],
      # notify    => Exec['make_db_tables'],
      before   => Exec['make_db_tables'],
    }

    #FIXME Work around a bug in v1.0.0 of the puppetlabs-mysql module that causes the <code>mysql_grant</code> type to notify on
    # every run by having the <code>mysql_database</code> resource created in the <code>mysql::db</code> define notify
    # <code>Exec['make_db_tables']</code> instead of using the more flexible notify from the entire define.
    Mysql_database[$db_database] ~> Exec['make_db_tables']
  }

  $make_db_tables_command = $::operatingsystem ? {
    /(Ubuntu|Debian)/ => '/usr/lib/bacula/make_bacula_tables',
    default           => '/usr/libexec/bacula/make_mysql_tables',
  }

  $db_parameters = "--host=${db_host} --user=${db_user} --password=${db_password} --port=${db_port} --database=${db_database}"

  exec { 'make_db_tables':
    command     => "${make_db_tables_command} ${db_parameters}",
    environment => "db_name=${db_database}",
    refreshonly => true,
    logoutput   => true,
    require     => Package[$db_package],
  }
}
