# == Define: bacula::client::config
#
# Install a config file describing a <code>bacula-fd</code> client on the director.
#
# === Parameters
#
# [*ensure*]
#   If the configuration should be deployed to the director. <code>file</code> (default), <code>present</code>, or
#   <code>absent</code>.
#
# [*backup_enable*]
#   If the backup job for the client should be enabled <code>true</code> (default) or <code>false</code>.
#
# [*client_schedule*]
#   The schedule for backups to be performed.
#
# [*db_backend*]
#   The database backend of the catalog storing information about the backup
#
# [*director_password*]
#   The director's password the client is connecting to.
#
# [*director_server*]
#   The FQDN of the director server the client will connect to.
#
# [*fileset*]
#   The file set used by the client for backups
#
# [*base*]
#   The job to use as a base.  Default to undef.
#
# [*accurate*]
#   Set Accurate = yes for job definition (defaults to now unless *base* is specified)
#
# [*jobdefs*]
#   Use defaults defined in the given JobDefs definition
#
# [*pool*]
#   The pool used by the client for backups
#
# [*pool_diff*]
#   The pool to use for differential backups. Setting this to <code>false</code> will prevent configuring a specific pool for
#   differential backups. Defaults to <code>"${pool}.differential"</code>.
#
# [*pool_full*]
#   The pool to use for full backups. Setting this to <code>false</code> will prevent configuring a specific pool for full backups.
#   Defaults to <code>"${pool}.full"</code>.
#
# [*pool_incr*]
#   The pool to use for incremental backups. Setting this to <code>false</code> will prevent configuring a specific pool for
#   incremental backups. Defaults to <code>"${pool}.incremental"</code>.
#
# [*maximum_bandwidth*]
#   Bandwidth limit for the bacula file director.  This can be used to prevent bacula from saturating network interfaces.
#
# [*allow_duplicate_jobs*]
#   Allow duplicate jobs, if set to no the second job may be canceled if the first job is still running
#
# [*priority*]
#   This directive permits you to control the order in which your jobs will be run by specifying a positive non-zero number. The
#   higher the number, the lower the job priority. Assuming you are not running concurrent jobs, all queued jobs of priority
#   <code>1</code> will run before queued jobs of priority <code>2</code> and so on, regardless of the original scheduling order.
#   The priority only affects waiting jobs that are queued to run, not jobs that are already running. If one or more jobs of
#   priority <code>2</code> are already running, and a new job is scheduled with priority <code>1</code>, the currently running
#   priority <code>2</code> jobs must complete before the priority <code>1</code> job is run, unless <code>Allow Mixed
#   Priority</code> is set. The default priority is <code>10</code>.
#
# [*rerun_failed_levels*]
#   If this directive is set to <code>true</code> (default <code>false</code>), and Bacula detects that a previous job at a higher
#   level (i.e. Full or Differential) has failed, the current job level will be upgraded to the higher level. This is particularly
#   useful for Laptops where they may often be unreachable, and if a prior Full save has failed, you wish the very next backup to be
#   a Full save rather than whatever level it is started as. There are several points that must be taken into account when using
#   this directive: first, a failed job is defined as one that has not terminated normally, which includes any running job of the
#   same name (you need to ensure that two jobs of the same name do not run simultaneously); secondly, the Ignore FileSet Changes
#   directive is not considered when checking for failed levels, which means that any FileSet change will trigger a rerun.
#
# [*restore_enable*]
#   If the restore job for the client should be enabled <code>true</code> (default) or <code>false</code>.
#
# [*restore_where*]
#   The default path to restore files to defined in the restore job for this client.
#
# [*run_scripts*]
#   An array of hashes containing the parameters for any
#   {RunScripts}[http://www.bacula.org/5.0.x-manuals/en/main/main/Configuring_Director.html#6971] to include in the backup job
#   definition. For each hash in the array a <code>RunScript</code> directive block will be inserted with the
#   <code>key = value</code> settings from the hash.  Note: The <code>RunsWhen</code> key is required.
#
# [*storage_server*]
#   The storage server hosting the pool this client will backup to
#
# [*tls_ca_cert_dir*]
#   Full path to TLS CA certificate directory. In the current implementation, certificates must be stored PEM
#   encoded with OpenSSL-compatible hashes, which is the subject name's hash and an extension of .0. One of
#   <tt>TLS CA Certificate File</tt> or <tt>TLS CA Certificate Dir</tt> are required in a server context if <tt>TLS Verify Peer</tt>
#   is also specified, and are always required in a client context.
#
# [*tls_ca_cert*]
#   The full path and filename specifying a PEM encoded TLS CA certificate(s). Multiple certificates are permitted in
#   the file. One of <code>TLS CA Certificate File</code> or <code>TLS CA Certificate Dir</code> are required in a server context if
#   <code>TLS Verify Peer</code> is also specified, and are always required in a client context.
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
# [*use_tls*]
#   Whether to use {Bacula TLS - Communications
#   Encryption}[http://www.bacula.org/en/dev-manual/main/main/Bacula_TLS_Communications.html].
#
# === Examples
#
#   bacula::client::config { 'client1.example.com' :
#     client_schedule   => 'WeeklyCycle',
#     db_backend        => 'mysql',
#     director_password => 'directorpassword',
#     director_server   => 'bacula.example.com',
#     fileset           => 'Basic:noHome',
#     base              => 'LinuxBase',
#     pool              => 'otherpool',
#     storage_server    => 'bacula.example.com',
#     jobdefs           => 'JobDefsName',
#   }
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

define bacula::client::config (
  String $ensure = file,
  Boolean $backup_enable = true,
  String $client_schedule               = 'WeeklyCycle',
  String $db_backend                    = 'sqlite',
  String $db_password                   = extlib::cache_data('bacula', 'db_password', extlib::random_password(32)),
  String $director_password             = extlib::cache_data('bacula', 'director_password', extlib::random_password(32)),
  String $director_server               = "bacula.${facts['domain']}",
  String $fileset                       = 'Basic:noHome',
  Optional[String] $base                = undef,
  Boolean $accurate                     = $base ? {
    undef   => false,
    default => true,
  },
  Optional[String] $jobdefs             = undef,
  String $pool                          = 'default',
  Optional[String] $pool_diff           = undef,
  Optional[String] $pool_full           = undef,
  Optional[String] $pool_incr           = undef,
  Optional[String] $maximum_bandwidth   = undef,
  Boolean $allow_duplicate_jobs         = false,
  Optional[String] $priority            = undef,
  Boolean $rerun_failed_levels          = false,
  Boolean $restore_enable               = true,
  String $restore_where                 = '/var/tmp/bacula-restores',
  Optional[Array[Hash]] $run_scripts    = undef,
  Optional[String] $storage_server      = "bacula.${facts['domain']}",
  Array[String] $tls_allowed_cn         = [],
  String $tls_ca_cert                   = '/var/lib/bacula/ssl/certs/ca.pem',
  Optional[String] $tls_ca_cert_dir     = undef,
  String $tls_cert                      = "/var/lib/bacula/ssl/certs/${::fqdn}.pem",
  String $tls_key                       = "/var/lib/bacula/ssl/private_keys/${::fqdn}.pem",
  Boolean $tls_require                  = true,
  Boolean $tls_verify_peer              = true,
  Boolean $use_tls                      = true,
  ) {

  include 'bacula::console'

  file { "/etc/bacula/bacula-dir.d/${name}.conf":
    ensure    => $ensure,
    owner     => 'bacula',
    group     => 'bacula',
    mode      => '0640',
    content   => template('bacula/client_config.erb'),
    notify    => Exec['bconsole reload'],
    show_diff => false,
  }
}
