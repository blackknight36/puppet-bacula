require 'spec_helper'

describe 'bacula::console::bat' do
  package = 'bacula-console-bat'
  it do
    is_expected.to contain_package(package)
        .with({
          :ensure => 'present',
        })
  end

  it do
    is_expected.to contain_file('/etc/bacula/bat.conf')
        .with({
          :ensure  => 'symlink',
          :target  => '/etc/bacula/bconsole.conf',
        })
        .that_requires("Package[#{package}]")
  end
end
