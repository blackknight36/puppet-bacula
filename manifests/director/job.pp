# == Define: bacula::director::job
#
# Configures a job to backup bacula clients.
#
# === Parameters
#
# [*ensure*]
#   Ensure the file is present or absent.  The only valid values are <tt>file</tt> or
#   <tt>absent+. Defaults to <tt>file</tt>.
#
# [*type*]
#   Type of job.  May be set to Backup or Restore.
#
# [*level*]
#   Backup level for the job.  May be set to Full, Differential, or Incremental.
#
# [*fileset*]
#   Name of the file set used by this job.
#
# [*storage*]
#   Name of the storage used by this job.
#
# [*messages*]
#   Name of the message queue used by this job.
#
# [*pool*]
#   Name of the storage pool used by this job.
#
# [*priority*]
#   Job priority.
#
# [*write_bootsrap*]
#   Location of the bootstrap file created by bacula.
#
# [*jobname*]
#   Name of the job.  Default value uses the resource title.
#
# [*client*]
#   Host name of the client to run the job on.
#
# [*jobdefs*]
#   Job definition used by bacula to configure this job.
#
# [*job_schedule*]
#   Schedule used to manage when the job runs.  This schedule must be created using
#   a bacula::director::schedule resource or a custom include file.
#
# === Examples
#
#   bacula::director::job { 'File_Server_Home' :
#     ensure   => file,
#     client   => 'host.example.com',
#     jobdefs  => 'Default',
#     job_schedule => 'FirstWeeklyCycle',
#   }

define bacula::director::job (
    Enum['file', 'present', 'absent'] $ensure = 'file',
    Optional[Enum['Backup', 'Restore']] $type = undef,
    Optional[Enum['Full', 'Differential', 'Incremental', 'Base']] $level = undef,
    Optional[String] $client = undef,
    Optional[String] $jobname = undef,
    Optional[String] $jobdefs = undef,
    Optional[String] $fileset = undef,
    Optional[String] $job_schedule = undef,
    Optional[String] $storage = undef,
    Optional[String] $messages = undef,
    Optional[String] $pool = undef,
    Optional[Integer] $priority = undef,
    Optional[String] $write_bootstrap = undef,
    Optional[String] $max_run_time = undef,
    # Required for dedupe using base jobs
    Optional[Boolean] $accurate = undef,
    # Required to avoid putting jobs in DB before completion (avoids cancelled jobs in the DB)
    Optional[Boolean] $spool_attributes = undef,
    ) {

    include 'bacula::director'

    file { "/etc/bacula/bacula-dir.d/custom-job-${name}.conf":
        ensure  => $ensure,
        owner   => 'bacula',
        group   => 'bacula',
        mode    => '0640',
        content => template('bacula/custom-job.conf.erb'),
        require => File['/etc/bacula/bacula-dir.conf'],
        before  => Service['bacula-dir'],
        notify  => Exec['bacula-dir reload'],
    }
}
