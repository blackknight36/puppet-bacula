require 'hiera'
require 'spec_helper'

describe 'bacula::storage' do
  redhat = {
    :hardwaremodels => 'x86_64',
    :supported_os   => [
      {
        'operatingsystem'        => 'RedHat',
        'operatingsystemrelease' => ['6', '7', '8'],
      },
      {
        'operatingsystem'        => 'Fedora',
        'operatingsystemrelease' => ['30'],
      },
    ],
  }

  let(:hiera_config) { 'spec/fixtures/hiera/hiera.yaml' }
  hiera = Hiera.new(:config => 'spec/fixtures/hiera/hiera.yaml')

  storage_package = hiera.lookup('bacula::storage::storage_package', nil, nil)

  on_supported_os(redhat).each do |os, facts|
    context "on #{os}" do
      context "SELinux enabled" do
        let(:facts) { facts.merge({ :selinux => true, }) }

        it do
          is_expected.to contain_selinux__fcontext('/mnt/bacula(/.*)?') .with({ :seltype => 'bacula_store_t' })
        end
      end

      context "SELinux disabled" do
        let(:facts) { facts.merge({ :selinux => false, }) }

        it do
          is_expected.not_to contain_selinux__fcontext('/mnt/bacula(/.*)?') .with({ :seltype => 'bacula_store_t' })
        end
      end
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      it { is_expected.to contain_class('bacula::common') }

      it do
        is_expected.to contain_package(storage_package)
            .with({
              :ensure => 'installed',
            })
      end

      ['/mnt/bacula', '/mnt/bacula/default'].each do |f|
        it do
          is_expected.to contain_file(f)
              .with({
                :ensure  => 'directory',
                :owner   => 'bacula',
                :group   => 'bacula',
                :mode    => '0755',
                :seltype => 'bacula_store_t',
              })
              .that_requires("Package[#{storage_package}]")
        end
      end

      it do
        is_expected.to contain_file('/etc/bacula/bacula-sd.d')
            .with({
              :ensure => 'directory',
              :owner  => 'bacula',
              :group  => 'bacula',
              :mode   => '0750',
            })
            .that_requires("Package[#{storage_package}]")
      end

      it do
        is_expected.to contain_file('/etc/bacula/bacula-sd.d/empty.conf')
            .with({
              :ensure => 'file',
              :owner  => 'bacula',
              :group  => 'bacula',
              :mode   => '0640',
            })
      end

      it do
        is_expected.to contain_file('/etc/bacula/bacula-sd.conf')
            .with({
              :ensure    => 'file',
              :owner     => 'bacula',
              :group     => 'bacula',
              :mode      => '0640',
              :show_diff => false,
            })
            .that_requires("Package[#{storage_package}]")
            .that_notifies('Service[bacula-sd]')
      end

      it do
        is_expected.to contain_service('bacula-sd')
            .with({
              :ensure     => 'running',
              :enable     => true,
              :hasstatus  => true,
              :hasrestart => true,
            })
      end
    end
  end
end
