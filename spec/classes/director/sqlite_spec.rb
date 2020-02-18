require 'spec_helper'

describe 'bacula::director::sqlite' do
  linux = {
    :hardwaremodels => 'x86_64',
    :supported_os   => [
      {
        'operatingsystem'        => 'CentOS',
      },
      {
        'operatingsystem'        => 'RedHat',
      },
      {
        'operatingsystem'        => 'Fedora',
      },
     ],
  }

  on_supported_os(linux).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge({ :osfamily => 'RedHat' })
      end

      p = 'bacula-storage-sqlite'

      it do
        is_expected.to contain_package(p) .with({ :ensure => 'installed' })
      end

      it do
        is_expected.to contain_sqlite__db("bacula")
            .with({
              "ensure"   => "present",
              "location" => "/var/lib/bacula/bacula.db",
              "owner"    => "bacula",
              "group"    => "bacula",
            })
      end

      it do
        is_expected.to contain_file("/usr/local/libexec/bacula")
            .with({
              "ensure" => "directory",
              "owner"  => "root",
              "group"  => "root",
              "mode"   => "0755",
            })
      end

      it do
        is_expected.to contain_file("/usr/local/libexec/bacula/make_sqlite3_tables.sh")
            .with({
              "owner" => "root",
              "group" => "root",
              "mode"  => "0755",
            })
            .that_requires("Package[#{p}]")
      end

      it do
        is_expected.to contain_exec("make_db_tables")
          .with({
            "command"     => '/usr/local/libexec/bacula/make_sqlite3_tables.sh',
            "refreshonly" => true,
          })
      end
    end
  end
end
