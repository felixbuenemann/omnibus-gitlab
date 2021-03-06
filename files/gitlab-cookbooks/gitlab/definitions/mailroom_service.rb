#
# Copyright:: Copyright (c) 2014 GitLab B.V.
# License:: Apache License, Version 2.0
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

define :mailroom_service, :rails_app => nil, :user => nil do
  svc = params[:name]
  user = params[:user]
  rails_app = params[:rails_app]

  mailroom_log_dir = node['gitlab']['gitlab-rails']['reply_by_email_log_directory']
  mail_room_config = File.join(node['gitlab']['gitlab-rails']['dir'], "etc", "mail_room.yml")

  directory mailroom_log_dir do
    owner user
    mode '0700'
    recursive true
  end

  runit_service svc do
    template_name 'mailroom'
    options({
      :rails_app => rails_app,
      :user => user,
      :log_directory => mailroom_log_dir,
      :mail_room_config => mail_room_config
    }.merge(params))
    log_options node['gitlab']['logging'].to_hash
  end

  if node['gitlab']['bootstrap']['enable']
    execute "/opt/gitlab/bin/gitlab-ctl start #{svc}" do
      retries 20
    end
  end
end
