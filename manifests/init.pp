# == Class: bacula
#
# This is the main class to manage all the components of a Bacula
# infrastructure. This is the only class that needs to be declared.
#
# === Parameters:
#
# [*backup_catalog*]
#   Perform a nightly backup of the catalog database from the director server. You may wish to set this to
#   <code>false</code> if you are maintaining your own database backups.
#
# [*clients*]
#   For directors, <tt>$clients</tt> is a hash of clients.  The keys are the clients while the value is a hash of parameters. The
#   parameters accepted are the same as the <tt>bacula::client::config</tt> define.
#
# [*console_password*]
#   The console's password
#
# [*console_template*]
#   The ERB template to use for configuring the bconsole instead of the one
#   included with the module
#
# [*db_backend*]
#   The database backend to use
#
# [*db_database*]
#   The db database to connect to on <tt>$db_host</tt>
#
# [*db_host*]
#   The db server host to connect to
#
# [*db_password*]
#   The password to authenticate <tt>$db_user</tt> with
#
# [*db_port*]
#   The port to connect to the database server on
#
# [*db_user*]
#   The user to authenticate to <tt>$db_db</tt> with.
#
# [*db_user_host*]
#   The host string used by MySQL to allow connections from
#
# [*director_password*]
#   The director's password
#
# [*director_server*]
#   The FQDN of the bacula director
#
# [*director_template*]
#   The ERB template to use for configuring the director instead of the one
#   included with the module
#
# [*is_client*]
#   Whether the node should be a client
#
# [*is_director*]
#   Whether the node should be a director
#
# [*is_storage*]
#   Whether the node should be a storage server
#
# [*logwatch_enabled*]
#   If <tt>manage_logwatch</tt> is <tt>true</tt> should the Bacula logwatch configuration be enabled or disabled
#
# [*mail_command*]
#   The {command}[http://www.bacula.org/5.0.x-manuals/en/main/main/Messages_Resource.html#12970] bacula will use to send mail. Defaults to <code>"/usr/sbin/bsmtp -h localhost -f bacula@${::fqdn} -s \"Bacula %t %e (for %c)\" %r"</code>.
#
# [*mail_to*]
#   Send the message to this email address for all jobs. Will default to <code>root@${::fqdn}</code> if it and
#   <code>mail_to_on_error</code> are left undefined.
#
# [*mail_to_daemon*]
#   Send daemon messages to this email address. Will default to either <code>$mail_to</code> or <code>$mail_to_on_error</code>
#   in that order if left undefined.
#
# [*mail_to_on_error*]
#   Send the message to this email address if the Job terminates with an error condition.
#
# [*mail_to_operator*]
#   Send the message to this email address. Will default to either <code>$mail_to</code> or <code>$mail_to_on_error</code> in
#   that order if left undefined.
#
# [*manage_bat*]
#   Whether the bat should be managed on the node
#
# [*manage_config_dir*]
#   Whether to purge all non-managed files from the bacula config directory
#
# [*manage_console*]
#   Whether bconsole should be managed on the node
#
# [*manage_db*]
#   Whether to manage the existence of the database.  If true, the <tt>$db_user</tt>
#   must have privileges to create databases on <tt>$db_host</tt>
#
# [*manage_db_tables*]
#   Whether to create the DB tables during install
#
# [*manage_logwatch*]
#   Whether to configure {logwatch}[http://www.logwatch.org/] on the director
#
# [*operator_command*]
#   The {command}[http://www.bacula.org/5.0.x-manuals/en/main/main/Messages_Resource.html#12997] bacula will use to send mail for Operator messages. Defaults to <code>"/usr/sbin/bsmtp -h localhost -f bacula@${::fqdn} -s \"Bacula Intervention Required (for %c)\" %r"</code>.
#
# [*plugin_dir*]
#   The directory Bacula plugins are stored in. Use this parameter if you are providing Bacula plugins for use. Only use if the package in the distro repositories supports plugins or you have included a respository with a newer Bacula packaged for your distro. If this is anything other than `undef` and you are not providing any plugins in this directory Bacula will throw an error every time it starts even if the package supports plugins.
#
# [*storage_default_mount*]
#   Directory where the default disk for file backups is mounted. A subdirectory named <tt>default</tt> will be created allowing you
#   to define additional devices in Bacula which use the same disk. Defaults to <tt>'/mnt/bacula'</tt>.
#
# [*storage_server*]
#   The FQDN of the storage server
#
# [*storage_template*]
#   The ERB template to use for configuring the storage daemon instead of the
#   one included with the module
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
# [*use_vol_purge_script*]
#   Run a script to automatically clean up old volumes from the default file pool after the BackupCatalog job is run each day. It
#   is only valid if the Director and the Storage daemon are running on the same host. <tt>true</tt> or <tt>false</tt> (default).
#
# [*use_vol_purge_mvdir*]
#   The volume purge script can move volume files to a side directory for further inspection instead of removing the volume files.
#   Bacula has a tendency (at least as of version 5.0.x) to occasionally label volume files incorrectly or store jobs in a volume
#   labeled differently than the job name. Takes an absolute file file path to a directory or <tt>undef</tt> the default.
#
# [*volume_autoprune*]
#   {Auto prune volumes}[http://www.bacula.org/5.0.x-manuals/en/main/main/Configuring_Director.html#AutoPrune] in
#   the default pool.
#
# [*volume_autoprune_diff*]
#   {Auto prune volumes}[http://www.bacula.org/5.0.x-manuals/en/main/main/Configuring_Director.html#AutoPrune] in
#   the default differential pool.
#
# [*volume_autoprune_full*]
#   {Auto prune volumes}[http://www.bacula.org/5.0.x-manuals/en/main/main/Configuring_Director.html#AutoPrune] in
#   the default full pool.
#
# [*volume_autoprune_incr*]
#   {Auto prune volumes}[http://www.bacula.org/5.0.x-manuals/en/main/main/Configuring_Director.html#AutoPrune] in
#   the default incremental pool.
#
# [*volume_retention*]
#   Length of time to {retain volumes}[http://www.bacula.org/5.0.x-manuals/en/main/main/Configuring_Director.html#VolRetention] in
#   the default pool.
#
# [*volume_retention_diff*]
#   Length of time to {retain volumes}[http://www.bacula.org/5.0.x-manuals/en/main/main/Configuring_Director.html#VolRetention] in
#   the default differential pool.
#
# [*volume_retention_full*]
#   Length of time to {retain volumes}[http://www.bacula.org/5.0.x-manuals/en/main/main/Configuring_Director.html#VolRetention] in
#   the default full pool.
#
# [*volume_retention_incr*]
#   Length of time to {retain volumes}[http://www.bacula.org/5.0.x-manuals/en/main/main/Configuring_Director.html#VolRetention] in
#   the default incremental pool.
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
#
# === Sample Usage
#
#  $clients = {
#    'node1.example.com' => {
#      'fileset'         => 'Basic:noHome',
#      'client_schedule' => 'Hourly',
#    },
#    'node2.example.com' => {
#      'fileset'         => 'Basic:noHome',
#      'client_schedule' => 'Hourly',
#    }
#  }
#
#  class { 'bacula':
#    is_storage        => true,
#    is_director       => true,
#    is_client         => true,
#    director_password => 'xxxxxxxxx',
#    console_password  => 'xxxxxxxxx',
#    director_server   => 'bacula.domain.com',
#    mail_to           => 'bacula-admin@domain.com',
#    storage_server    => 'bacula.domain.com',
#    clients           => $clients,
#  }
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

class bacula (
  Boolean $backup_catalog                = true,
  Optional[Hash] $clients                = undef,
  String $console_password               = extlib::cache_data('bacula', 'console_password', extlib::random_password(32)),
  Optional[String] $console_template     = undef,
  String $db_backend                     = 'sqlite',
  String $db_database                    = 'bacula',
  String $db_host                        = 'localhost',
  String $db_password                    = extlib::cache_data('bacula', 'db_password', extlib::random_password(32)),
  Optional[String] $db_port              = undef,
  String $db_user                        = 'bacula',
  Optional[String] $db_user_host         = undef,
  String $director_password              = extlib::cache_data('bacula', 'director_password', extlib::random_password(32)),
  String $director_server                = $facts['fqdn'],
  Optional[String] $director_template    = undef,
  Boolean $is_client                     = true,
  Boolean $is_director                   = false,
  Boolean $is_storage                    = false,
  Boolean $logwatch_enabled              = true,
  String $mail_command                   = "/usr/sbin/bsmtp -h localhost -f bacula@${facts['fqdn']} -s \\\"Bacula %t %e (for %c)\\\" %r",
  String $mail_to                        = "root@${facts['fqdn']}",
  Optional[String] $mail_to_daemon       = $mail_to,
  Optional[String] $mail_to_on_error     = $mail_to,
  Optional[String] $mail_to_operator     = $mail_to,
  Boolean $manage_bat                    = false,
  Boolean $manage_config_dir             = false,
  Boolean $manage_console                = false,
  Boolean $manage_db                     = true,
  Boolean $manage_db_tables              = true,
  Boolean $manage_logwatch               = true,
  String $operator_command               = "/usr/sbin/bsmtp -h localhost -f bacula@${::fqdn} -s \\\"Bacula Intervention Required (for %c)\\\" %r",
  String $plugin_dir                     = '/usr/lib64/bacula',
  String $storage_default_mount          = '/mnt/bacula',
  String $storage_server                 = $director_server,
  Optional[String] $storage_template     = undef,
  Array[String] $tls_allowed_cn          = [],
  String $tls_ca_cert                    = '/var/lib/bacula/ssl/certs/ca.pem',
  Optional[String] $tls_ca_cert_dir      = undef,
  String $tls_cert                       = "/var/lib/bacula/ssl/certs/${::fqdn}.pem",
  String $tls_key                        = "/var/lib/bacula/ssl/private_keys/${::fqdn}.pem",
  Boolean $tls_require                   = true,
  Boolean $tls_verify_peer               = true,
  Boolean $use_tls                       = true,
  Boolean $use_vol_purge_script          = false,
  Boolean $use_vol_purge_mvdir           = false,
  Boolean $volume_autoprune              = true,
  Boolean $volume_autoprune_diff         = true,
  Boolean $volume_autoprune_full         = true,
  Boolean $volume_autoprune_incr         = true,
  String $volume_retention               = '1 Year',
  String $volume_retention_diff          = '40 Days',
  String $volume_retention_full          = '1 Year',
  String $volume_retention_incr          = '10 Days',
  Boolean $pki_encryption                = false,
  Boolean $manage_pki_keypair            = true,
  String $pki_keypair                    = '/var/lib/bacula/ssl/encryption_keypair.pem',
  String $pki_master_key                 = '/var/lib/bacula/ssl/certs/master.crt',
  ) {

  include 'bacula::common'

  if $is_director {
    class { 'bacula::director':
      backup_catalog        => $backup_catalog,
      clients               => $clients,
      console_password      => $console_password,
      db_backend            => $db_backend,
      db_database           => $db_database,
      db_host               => $db_host,
      db_password           => $db_password,
      db_port               => $db_port,
      db_user               => $db_user,
      db_user_host          => $db_user_host,
      dir_template          => $director_template,
      director_password     => $director_password,
      director_server       => $director_server,
      mail_command          => $mail_command,
      mail_to               => $mail_to,
      mail_to_daemon        => $mail_to_daemon,
      mail_to_on_error      => $mail_to_on_error,
      mail_to_operator      => $mail_to_operator,
      manage_config_dir     => $manage_config_dir,
      manage_db             => $manage_db,
      manage_db_tables      => $manage_db_tables,
      manage_logwatch       => $manage_logwatch,
      operator_command      => $operator_command,
      plugin_dir            => $plugin_dir,
      storage_server        => $storage_server,
      tls_allowed_cn        => $tls_allowed_cn,
      tls_ca_cert           => $tls_ca_cert,
      tls_ca_cert_dir       => $tls_ca_cert_dir,
      tls_cert              => $tls_cert,
      tls_key               => $tls_key,
      tls_require           => $tls_require,
      tls_verify_peer       => $tls_verify_peer,
      use_tls               => $use_tls,
      use_vol_purge_script  => $use_vol_purge_script,
      use_vol_purge_mvdir   => $use_vol_purge_mvdir,
      volume_autoprune      => $volume_autoprune,
      volume_autoprune_diff => $volume_autoprune_diff,
      volume_autoprune_full => $volume_autoprune_full,
      volume_autoprune_incr => $volume_autoprune_incr,
      volume_retention      => $volume_retention,
      volume_retention_diff => $volume_retention_diff,
      volume_retention_full => $volume_retention_full,
      volume_retention_incr => $volume_retention_incr,
    }

    if $manage_logwatch {
      class { 'bacula::director::logwatch':
        logwatch_enabled => $logwatch_enabled,
      }
    }
  }

  if $is_storage {
    class { 'bacula::storage':
      console_password      => $console_password,
      db_backend            => $db_backend,
      director_password     => $director_password,
      director_server       => $director_server,
      plugin_dir            => $plugin_dir,
      storage_default_mount => $storage_default_mount,
      storage_server        => $storage_server,
      storage_template      => $storage_template,
      tls_allowed_cn        => $tls_allowed_cn,
      tls_ca_cert           => $tls_ca_cert,
      tls_ca_cert_dir       => $tls_ca_cert_dir,
      tls_cert              => $tls_cert,
      tls_key               => $tls_key,
      tls_require           => $tls_require,
      tls_verify_peer       => $tls_verify_peer,
      use_tls               => $use_tls,
    }
  }

  if $is_client {
    class { 'bacula::client':
      director_server   => $director_server,
      director_password => $director_password,
      plugin_dir        => $plugin_dir,
      tls_allowed_cn    => $tls_allowed_cn,
      tls_ca_cert       => $tls_ca_cert,
      tls_ca_cert_dir   => $tls_ca_cert_dir,
      tls_cert          => $tls_cert,
      tls_key           => $tls_key,
      tls_require       => $tls_require,
      tls_verify_peer   => $tls_verify_peer,
      use_tls           => $use_tls,
      pki_encryption    => $pki_encryption,
      pki_keypair       => $pki_keypair,
      pki_master_key    => $pki_master_key,
    }
  }

  if $manage_console {
    include 'bacula::console'
  }

  if $manage_bat {
    include 'bacula::console::bat'
  }
}
