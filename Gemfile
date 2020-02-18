# This file is part of the blackknight36-snmp puppet module.
# Copyright 2020 Michael Watters <wattersm@watters.ws>
# SPDX-License-Identifier: GPL-3.0-or-later

source 'https://rubygems.org'

puppetversion = ENV.key?('PUPPET_VERSION') ? "= #{ENV['PUPPET_VERSION']}" : ['= 5.0.0']

gem "rake", "~> 12.0"

gem 'puppet', puppetversion
gem "puppetlabs_spec_helper", "~> 2.2"

gem 'rspec', '>= 3.4.4'
gem 'rspec-puppet', '>= 2.1.0'
gem 'rspec-puppet-facts', '>= 1.8.0'
gem 'rspec-puppet-utils', '>= 3.4.0'

gem "beaker", "~> 3.17"
gem "beaker-rspec", "~> 6.1"
gem "beaker-puppet_install_helper", "~> 0.7.1"

gem "serverspec", "~> 2.39"

gem "puppet-syntax", "~> 2.4"
gem "puppet-lint", "~> 2.2"
gem "metadata-json-lint", "~> 2.0.1"
gem "yaml-lint", "~> 0.0.9"

gem "puppet-strings", "~> 1.1.0"

# Coveralls.io coverage report
gem 'coveralls', require: false
