require 'spec_helper'

describe 'bacula' do
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

  let(:node) { 'bacula.example.com' }

  on_supported_os(redhat).each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context "bacula::common include" do
        it do
          is_expected.to contain_class('bacula::common')
              .with({
                'manage_config_dir' => false,
                'manage_db_tables'  => true,
              })
        end
      end

      context "bacula::director node" do
        let(:params) {{
          :is_director => true,
        }}

        mailto = 'root@bacula.example.com'
        it do
          is_expected.to contain_class('bacula::director')
              .with({
                'backup_catalog' => true,
                'clients' => nil,
                'console_password' => %r{\w{32}},
                'db_backend' => 'sqlite',
                'dir_template' => 'bacula/bacula-dir.conf.erb',
                'director_password' => %r{\w{32}},
                'director_server' => 'bacula.example.com',
                'mail_command' => "/usr/sbin/bsmtp -h localhost -f bacula@bacula.example.com -s \\\"Bacula %t %e (for %c)\\\" %r",
                'mail_to' => [mailto],
                'mail_to_daemon' => mailto,
                'mail_to_on_error' => mailto,
                'mail_to_operator' => mailto,
                'manage_config_dir' => false,
                'manage_db' => true,
                'manage_db_tables' => true,
                'manage_logwatch' => true,
                'operator_command' => "/usr/sbin/bsmtp -h localhost -f bacula@bacula.example.com -s \\\"Bacula Intervention Required (for %c)\\\" %r",
                'plugin_dir' => '/usr/lib64/bacula',
                'storage_server' => 'bacula.example.com',
                'tls_allowed_cn' => [],
                'tls_ca_cert' => '/var/lib/bacula/ssl/certs/ca.pem',
                'tls_ca_cert_dir' => nil,
                'tls_cert' => "/var/lib/bacula/ssl/certs/#{node}.pem",
                'tls_key' => "/var/lib/bacula/ssl/private_keys/#{node}.pem",
                'tls_require' => true,
                'tls_verify_peer' => true,
                'use_tls' => true,
                'use_vol_purge_script' => false,
                'use_vol_purge_mvdir' => false,
                'volume_autoprune' => true,
                'volume_autoprune_diff' => true,
                'volume_autoprune_full' => true,
                'volume_autoprune_incr' => true,
                'volume_retention' => '1 Year',
                'volume_retention_diff' => '40 Days',
                'volume_retention_full' => '1 Year',
                'volume_retention_incr' => '10 Days',
              })
        end

        context "manage_logwatch => true" do
          let(:params) {{
            :is_director      => true,
            :manage_logwatch  => true,
          }}

          it do
            is_expected.to contain_class('bacula::director::logwatch')
                .with({
                  'logwatch_enabled' => true,
                })
          end
        end

        context "manage_console => true" do
          let(:params) {{
            :is_director    => true,
            :manage_console => true,
          }}

          it do
            is_expected.to contain_class('bacula::console')
          end
        end
      end

      context "bacula storage node" do
        let(:params) {{
          :is_storage => true,
        }}

        it do
          is_expected.to contain_class('bacula::storage')
              .with({
                'console_password' => %r{\w{32}},
                'db_backend' => 'sqlite',
                'director_password' => %r{\w{32}},
                'director_server' => 'bacula.example.com',
                'plugin_dir' => '/usr/lib64/bacula',
                'storage_default_mount' => '/mnt/bacula',
                'storage_server' => 'bacula.example.com',
                'storage_template' => 'bacula/bacula-sd.conf.erb',
                'tls_allowed_cn' => [],
                'tls_ca_cert' => '/var/lib/bacula/ssl/certs/ca.pem',
                'tls_ca_cert_dir' => nil,
                'tls_cert' => "/var/lib/bacula/ssl/certs/bacula.example.com.pem",
                'tls_key' => "/var/lib/bacula/ssl/private_keys/bacula.example.com.pem",
                'tls_require' => true,
                'tls_verify_peer' => true,
                'use_tls' => true,
              })
        end
      end

      context "bacula client node" do
        let(:params) {{
          :is_client => true,
        }}

        it do
          is_expected.to contain_class('bacula::client')
              .with({
                'director_server' => 'bacula.example.com',
                'director_password' => %r{\w{32}},
                'plugin_dir' => '/usr/lib64/bacula',
                'tls_allowed_cn' => [],
                'tls_ca_cert' => '/var/lib/bacula/ssl/certs/ca.pem',
                'tls_ca_cert_dir' => nil,
                'tls_cert' => "/var/lib/bacula/ssl/certs/bacula.example.com.pem",
                'tls_key' => "/var/lib/bacula/ssl/private_keys/bacula.example.com.pem",
                'tls_require' => true,
                'tls_verify_peer' => true,
                'use_tls' => true,
              })
        end
      end

      context "manage_bat => true" do
        let(:params) {{
          :manage_bat => true,
        }}

        it do
          is_expected.to contain_class('bacula::console::bat')
        end
      end

    end
  end
end
