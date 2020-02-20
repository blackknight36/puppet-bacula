# == Class: bacula
#
# This is the main class to manage all the components of a Bacula
# infrastructure. This is the only class that needs to be declared.
#
# === Parameters:
#
# [*is_client*]
#   Whether the node should be a client
#
# [*is_director*]
#   Whether the node should be a director
#
# [*is_storage*]
#   Whether the node should be a storage server
#
# === Copyright
#
# Copyright 2020 Michael Watters
#
# === License
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class bacula (
  Boolean $is_client                     = true,
  Boolean $is_director                   = false,
  Boolean $is_storage                    = false,
  Boolean $manage_bat                    = false,
  ) {

  include 'bacula::common'

  if $is_director {
    include 'bacula::director'
  }

  if $is_storage {
    include 'bacula::storage'
  }

  if $is_client {
    include 'bacula::client'
  }

  if $manage_console {
    include 'bacula::console'
  }

  if $manage_bat {
    include 'bacula::console::bat'
  }
}
