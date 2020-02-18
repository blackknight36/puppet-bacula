require 'spec_helper'

describe 'bacula::client::config' do
  let(:title) { 'host.example.com' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) {{
          #:ensure => "file",
          #:backup_enable => "yes",
          #:client_schedule => "WeeklyCycle",
          #:db_backend => :undef,
          #:director_password => "",
          #:director_server => :undef,
          #:fileset => "Basic:noHome",
          #:base => :undef,
          #:pool => "default",
          #:pool_diff => :undef,
          #:pool_full => :undef,
          #:pool_incr => :undef,
          #:maximum_bandwidth => :undef,
          #:priority => :undef,
          #:rerun_failed_levels => "no",
          #:restore_enable => "yes",
          #:restore_where => "/var/tmp/bacula-restores",
          #:run_scripts => :undef,
          #:storage_server => :undef,
          #:tls_allowed_cn => [],
          #:tls_ca_cert => :undef,
          #:tls_ca_cert_dir => :undef,
          #:tls_cert => :undef,
          #:tls_key => :undef,
          #:tls_require => "yes",
          #:tls_verify_peer => "yes",
          #:use_tls => false,
        }}

        it do
          is_expected.to contain_file("/etc/bacula/bacula-dir.d/host.example.com.conf")
              .with({
                :ensure => "file",
                :owner  => "bacula",
                :group  => "bacula",
                :mode   => "0640",
                :show_diff => false,
              })
              .that_notifies('Exec[bacula-dir reload]')
              #.that_comes_before('Service[bacula-dir]')
        end
    end
  end

end
