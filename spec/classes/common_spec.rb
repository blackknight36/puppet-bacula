require 'spec_helper'

describe 'bacula::common' do
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

      it do
        is_expected.to contain_package('bacula-common') .with({ 'ensure' => 'installed', })
      end

      it do
        is_expected.to contain_file('/usr/lib64/bacula')
      end

      it do
        is_expected.to contain_file('/etc/bacula')
            .with({
              :ensure  => 'directory',
              :owner   => 'bacula',
              :group   => 'bacula',
              :mode    => '0750',
              :purge   => false,
              :force   => false,
              :recurse => false,
              :source  => nil,
            })
            .that_requires('Package[bacula-common]')
      end

      it do
        is_expected.to contain_file('/etc/bacula/scripts')
            .with({
              'ensure' => 'directory',
              'owner' => 'bacula',
              'group' => 'bacula',
            })
            .that_requires('Package[bacula-common]')
      end

      it do
        is_expected.to contain_file('/var/lib/bacula')
            .with({
              :ensure  => 'directory',
              :owner   => 'bacula',
              :group   => 'root',
              :mode    => '0775',
            })
      end

      it do
        is_expected.to contain_file('/var/spool/bacula')
            .with({
              'ensure' => 'directory',
              'owner' => 'bacula',
              'group' => 'bacula',
              'mode' => '0755',
            })
            .that_requires('Package[bacula-common]')
      end

      it do
        is_expected.to contain_file('/var/log/bacula')
            .with({
              'ensure' => 'directory',
              'recurse' => true,
              'owner' => 'bacula',
              'group' => 'bacula',
              'mode' => '0755',
            })
            .that_requires('Package[bacula-common]')
      end
    end
  end
end
