require 'spec_helper'

describe 'bacula::client' do
  windows = {
    :hardwaremodels => 'x64',
    :supported_os   => [
      {
        'operatingsystem' => 'windows',
        'operatingsystemrelease' => ['7', '10'],
      },
    ],
  }

  redhat = {
    :hardwaremodels => 'x86_64',
    :supported_os   => [
      {
        'operatingsystem'        => 'CentOS',
        'operatingsystemrelease' => ['6', '7', '8'],
      },
      {
        'operatingsystem'        => 'RedHat',
        'operatingsystemrelease' => ['6', '7', '8'],
      },
      {
        'operatingsystem'        => 'Fedora',
      },
     ],
  }

  on_supported_os(redhat).each do |os, facts|
    let(:node) { 'example-host.example.com' }

    context "on #{os}" do
      let(:facts) do
        facts
      end

      context "SELinux enabled" do
        let(:facts) {
          facts.merge({ :selinux => true })
        }

        it do
          is_expected.to contain_selinux__module('bacula_fd_fix')
            .with({
              :source_te => 'puppet:///modules/bacula/selinux/bacula_fd_fix.te',
            })
            .that_comes_before('Service[bacula-fd]')
        end
      end
    end
  end

  on_supported_os(redhat).each do |os, facts|
    context "on #{os}" do
      let(:node) { 'example-host.example.com' }

      let(:facts) do
        facts
      end

      package        = 'bacula-client'
      tls_ca_cert    = '/var/lib/bacula/ssl/certs/ca.pem'
      tls_cert       = "/var/lib/bacula/ssl/certs/example-host.example.com.pem"
      tls_key        = "/var/lib/bacula/ssl/private_keys/example-host.example.com.pem"
      puppet_ssl_dir = facts[:operatingsystem] == 'Fedora' ? '/etc/puppet/ssl':'/etc/puppetlabs/puppet/ssl'

      it do
        is_expected.to contain_class('bacula::common')
      end

      it do
        is_expected.to contain_package(package) .with({ :ensure => 'installed' })
      end

      it do
        is_expected.to contain_file('bacula-fd.conf')
            .with({
              :ensure => 'file',
            })
            .that_notifies('Service[bacula-fd]')
            .that_requires("Package[#{package}]")
      end

      it do
        is_expected.to contain_service('bacula-fd')
            .with({
              :ensure     => 'running',
              :enable     => true,
              :hasstatus  => true,
              :hasrestart => true,
            })
            .that_requires('File[bacula-fd.conf]')
      end

      it do
        is_expected.to contain_file(tls_ca_cert)
            .with({
              :show_diff => false,
              :source => "file://#{puppet_ssl_dir}/certs/ca.pem",
            })
            .that_requires('File[/var/lib/bacula/ssl/certs]')
      end

      it do
        is_expected.to contain_file(tls_cert)
            .with({
              :show_diff => false,
              :source => "file://#{puppet_ssl_dir}/certs/#{node}.pem",
            })
            .that_requires('File[/var/lib/bacula/ssl/certs]')
      end

      it do
        is_expected.to contain_file(tls_key)
            .with({
              :show_diff => false,
              :source => "file://#{puppet_ssl_dir}/private_keys/#{node}.pem",
            })
            .that_requires('File[/var/lib/bacula/ssl/private_keys]')
      end
    end
  end

  on_supported_os(windows).each do |os, facts|
    let(:node) { 'example-host.example.com' }

    context "on #{os}" do
      let(:facts) do
        facts
      end

      puppet_ssl_dir = 'C:/ProgramData/PuppetLabs/puppet/etc/ssl'
      tls_ca_cert    = 'C:/ProgramData/Bacula/lib/ssl/certs/ca.pem'
      tls_cert       = "C:/ProgramData/Bacula/lib/ssl/certs/example-host.example.com.pem"
      tls_key        = "C:/ProgramData/Bacula/lib/ssl/private_keys/example-host.example.com.pem"

      it do
        is_expected.to contain_class('bacula::common')
      end

      it do
        is_expected.to contain_package('bacula') .with({ :ensure => 'installed' })
      end

      it do
        is_expected.to contain_file('bacula-fd.conf')
            .with({
              :ensure => 'file',
            })
            .that_notifies('Service[bacula-fd]')
            .that_requires('Package[bacula]')
      end

      it do
        is_expected.to contain_service('bacula-fd')
            .with({
              :ensure     => 'running',
              :enable     => true,
              :hasstatus  => true,
              :hasrestart => true,
            })
            .that_requires('File[bacula-fd.conf]')
      end

      it do
        is_expected.to contain_file(tls_ca_cert)
            .with({
              :show_diff => false,
              :source => "file://#{puppet_ssl_dir}/certs/ca.pem",
            })
            .that_requires('File[C:/ProgramData/Bacula/lib/ssl/certs]')
      end

      it do
        is_expected.to contain_file(tls_cert)
            .with({
              :show_diff => false,
              :source => "file://#{puppet_ssl_dir}/certs/#{node}.pem",
            })
            .that_requires('File[C:/ProgramData/Bacula/lib/ssl/certs]')
      end


      it do
        is_expected.to contain_file(tls_key)
            .with({
              :show_diff => false,
              :source => "file://#{puppet_ssl_dir}/private_keys/#{node}.pem",
            })
            .that_requires('File[C:/ProgramData/Bacula/lib/ssl/private_keys]')
      end
    end
  end
end
