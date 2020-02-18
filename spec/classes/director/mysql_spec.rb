require 'spec_helper'

describe 'bacula::director::mysql' do
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

      p = 'bacula-storage-mysql'

      it do
        is_expected.to contain_package(p)
      end

      it do
        is_expected.to contain_mysql__db('bacula')
            .with({
              'user'     => 'bacula',
              'password' => %r{\w{32}},
              'host'     => 'localhost',
              'grant'    => ['ALL'],
            })
            .that_comes_before('Exec[make_db_tables]')
      end

      it do
        is_expected.to contain_exec('make_db_tables')
            .with({
              :environment  => 'db_name=bacula',
              :creates      => '/etc/bacula/tables_created',
              :logoutput    => true,
            })
            .that_requires('Package[bacula-storage-mysql]')
      end
    end
  end
end
