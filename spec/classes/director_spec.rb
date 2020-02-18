require 'spec_helper'

describe 'bacula::director' do
  redhat = {
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

  on_supported_os(redhat).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:params) {{
        :manage_config_dir => true,
      }}

      p = 'bacula-director'

      it do
        is_expected.to contain_package(p)
            .with({
              :ensure => 'installed',
            })
      end

      it do
        is_expected.to contain_class('bacula::director::sqlite')
      end

      #context 'SELinux enabled' do
      #  let(:facts) {
      #    facts.merge({ :selinux => true, })
      #  }

      #  it do
      #    is_expected.to contain_selinux__module('bacula_dir')
      #        .with({
      #          :source => 'puppet:///modules/bacula/selinux',
      #        })
      #  end
      #end

      it do
        is_expected.to contain_file('/etc/bacula/bacula-dir.d')
            .with({
              :ensure  => 'directory',
              :owner   => 'bacula',
              :group   => 'bacula',
              :mode    => '0750',
              :purge   => true,
              :force   => true,
              :recurse => true,
              :source  => 'puppet:///modules/bacula/bacula-empty.dir',
            })
            .that_notifies('Exec[bacula-dir reload]')
            .that_requires("Package[#{p}]")
      end

      it do
        is_expected.to contain_file('/etc/bacula/bacula-dir.d/empty.conf')
            .with({
              'ensure' => 'file',
              'owner' => 'bacula',
              'group' => 'bacula',
              'mode' => '0640',
              'content' => '',
            })
      end

      it do
        is_expected.to contain_file('/usr/local/bin/bacula-prune-all-volumes.sh')
            .with({
              :ensure => 'absent',
              :owner  => 'bacula',
              :group  => 'bacula',
              :mode   => '0750',
              :before => 'File[/etc/bacula/bacula-dir.conf]',
            })
      end

      it do
        is_expected.to contain_file('/etc/bacula/bacula-dir.conf')
            .with({
              :ensure    => 'file',
              :owner     => 'bacula',
              :group     => 'bacula',
              :mode      => '0640',
              :show_diff => false,
            })
            .that_comes_before('Service[bacula-dir]')
            .that_notifies('Exec[bacula-dir reload]')
      end

      context 'managed mysql backend' do
        let(:params) {{
          :db_backend       => 'mysql',
          :manage_db        => true,
          :manage_db_tables => true,
        }}

        it do
          is_expected.to contain_class('bacula::director::mysql')
              .with({
                'db_database'   => 'bacula',
                'db_user'       => 'bacula',
                'db_password'   => %r{\w{32}},
                'db_port'       => '3306',
                'db_host'       => 'localhost',
                'db_user_host'  => 'localhost',
                'manage_db'     => true,
                })
        end

        it do
            is_expected.to contain_mysql__db('bacula')
                .with({
                  :ensure   => 'present',
                  :user     => 'bacula',
                  :password => %r{\w{32}},
                  :host     => 'localhost',
                  :grant    => ['ALL'],
                })
        end
      end

      context 'managed postgresql backend' do
        let(:params) {{
          :db_backend       => 'postgresql',
          :manage_db        => true,
          :manage_db_tables => true,
        }}

        it do
          is_expected.to contain_class('bacula::director::postgresql')
              .with({
                :db_database  => 'bacula',
                :db_user      => 'bacula',
                :db_password  => %r{\w{32}},
                :db_port      => '5432',
                :db_host      => 'localhost',
                :db_user_host => 'localhost',
                :manage_db    => true,
              })
        end
      end

      it do
        is_expected.to contain_service('bacula-dir')
            .with({
              'ensure' => 'running',
              'name' => 'bacula-dir',
              'enable' => true,
              'hasstatus' => true,
              'hasrestart' => true,
            })
            .that_requires('Exec[make_db_tables]')
            .that_requires('File[/etc/bacula/bacula-dir.conf]')
      end
   end

 end
end
