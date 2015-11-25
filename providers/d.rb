#
# Cookbook Name:: cron
# Provider:: d
#
# Copyright 2010-2015, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# This pattern is used to make the providers compatible with Chef 10,
# which does not support use_inline_resources.
#
# FIXME: replace when Chef 12 is released.

action :delete do
  r = create_template
  r.action :delete
  new_resource.updated_by_last_action(r.updated_by_last_action?)
end

action :create do
  # We should be able to switch emulate_cron.d on for Solaris, but I don't have a Solaris box to verify
  fail 'Solaris does not support cron jobs in /etc/cron.d' if node['platform_family'] == 'solaris2'
  r = create_template
  new_resource.updated_by_last_action(r.updated_by_last_action?)
end

def create_template
  template "/etc/cron.d/#{new_resource.name}" do
    cookbook new_resource.cookbook
    source 'cron.d.erb'
    mode new_resource.mode
    variables(
      name: new_resource.name,
      predefined_value: new_resource.predefined_value,
      minute: new_resource.minute,
      hour: new_resource.hour,
      day: new_resource.day,
      month: new_resource.month,
      weekday: new_resource.weekday,
      command: new_resource.command,
      user: new_resource.user,
      mailto: new_resource.mailto,
      path: new_resource.path,
      home: new_resource.home,
      shell: new_resource.shell,
      comment: new_resource.comment,
      environment: new_resource.environment
    )
    action :create
    notifies :create, 'template[/etc/crontab]', :delayed if node['cron']['emulate_cron.d']
  end
end
