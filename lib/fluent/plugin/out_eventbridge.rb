#
# Copyright 2023- kaija
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

require 'fluent/plugin/output'
require 'aws-sdk-eventbridge'

module Fluent::Plugin
  class AwsEventBridgeOutput < Fluent::Plugin::Output
    Fluent::Plugin.register_output('eventbridge', self)

    config_param :aws_key_id, :string, default: nil, secret: true
    desc 'AWS secret key.'
    config_param :aws_sec_key, :string, default: nil, secret: true
    config_section :assume_role_credentials, multi: false do
      desc 'The Amazon Resource Name (ARN) of the role to assume'
      config_param :role_arn, :string, secret: true
      desc 'An identifier for the assumed role session'
      config_param :role_session_name, :string
      desc 'An IAM policy in JSON format'
      config_param :policy, :string, default: nil
      desc 'The duration, in seconds, of the role session (900-3600)'
      config_param :duration_seconds, :integer, default: nil
      desc "A unique identifier that is used by third parties when assuming roles in their customers' accounts."
      config_param :external_id, :string, default: nil, secret: true
      desc 'The region of the STS endpoint to use.'
      config_param :sts_region, :string, default: nil
      desc 'A http proxy url for requests to aws sts service'
      config_param :sts_http_proxy, :string, default: nil, secret: true
      desc 'A url for a regional sts api endpoint, the default is global'
      config_param :sts_endpoint_url, :string, default: nil
    end
    # See the following link for additional params that could be added:
    # https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/STS/Client.html#assume_role_with_web_identity-instance_method
    config_section :web_identity_credentials, multi: false do
      desc 'The Amazon Resource Name (ARN) of the role to assume'
      config_param :role_arn, :string # required
      desc 'An identifier for the assumed role session'
      config_param :role_session_name, :string # required
      desc 'The absolute path to the file on disk containing the OIDC token'
      config_param :web_identity_token_file, :string # required
      desc 'An IAM policy in JSON format'
      config_param :policy, :string, default: nil
      desc 'The duration, in seconds, of the role session (900-43200)'
      config_param :duration_seconds, :integer, default: nil
      desc 'The region of the STS endpoint to use.'
      config_param :sts_region, :string, default: nil
    end
    config_section :instance_profile_credentials, multi: false do
      desc 'Number of times to retry when retrieving credentials'
      config_param :retries, :integer, default: nil
      desc 'IP address (default:169.254.169.254)'
      config_param :ip_address, :string, default: nil
      desc 'Port number (default:80)'
      config_param :port, :integer, default: nil
      desc 'Number of seconds to wait for the connection to open'
      config_param :http_open_timeout, :float, default: nil
      desc 'Number of seconds to wait for one block to be read'
      config_param :http_read_timeout, :float, default: nil
      # config_param :delay, :integer or :proc, :default => nil
      # config_param :http_degub_output, :io, :default => nil
    end
    config_section :shared_credentials, multi: false do
      desc 'Path to the shared file. (default: $HOME/.aws/credentials)'
      config_param :path, :string, default: nil
      desc "Profile name. Default to 'default' or ENV['AWS_PROFILE']"
      config_param :profile_name, :string, default: nil
    end
    config_param :aws_region, :string, default: 'ap-northeast-1'
    config_param :event_bus_name, :string, default: 'default'
    config_param :batch_size, :integer, default: 15
    config_param :source_key, :string, default: 'source'
    config_param :detail_type_key, :string, default: 'event_type'
    config_param :time_key, :string, default: 'time'

    def configure(conf)
      super
    end

    def start
      options = setup_credentials
      @eventbridge = Aws::EventBridge::Client.new(options)
      super
    end

    def process(_tag, es)
      es.each_slice(@batch_size) do |_batch|
        es.each do |_time, record|
          source = record[@source_key]
          detail_type = record[@detail_type_key]
          event_time = record[@time_key] ? Time.parse(record[@time_key]) : Time.now

          event_params = {
            source: source,
            detail_type: detail_type,
            time: event_time,
            detail: record.to_json
          }

          send_event_to_eventbridge(event_params)
        end
      end
    end

    private

    def setup_credentials
      options = {}
      credentials_options = {}
      if @assume_role_credentials
        c = @assume_role_credentials
        iam_user_credentials = @aws_key_id && @aws_sec_key ? Aws::Credentials.new(@aws_key_id, @aws_sec_key) : nil
        region = c.sts_region || @aws_region
        credentials_options[:role_arn] = c.role_arn
        credentials_options[:role_session_name] = c.role_session_name
        credentials_options[:policy] = c.policy if c.policy
        credentials_options[:duration_seconds] = c.duration_seconds if c.duration_seconds
        credentials_options[:external_id] = c.external_id if c.external_id
        credentials_options[:sts_endpoint_url] = c.sts_endpoint_url if c.sts_endpoint_url
        credentials_options[:sts_http_proxy] = c.sts_http_proxy if c.sts_http_proxy
        if c.sts_http_proxy && c.sts_endpoint_url
          credentials_options[:client] = if iam_user_credentials
                                           Aws::STS::Client.new(region: region, http_proxy: c.sts_http_proxy, endpoint: c.sts_endpoint_url, credentials: iam_user_credentials)
                                         else
                                           Aws::STS::Client.new(region: region, http_proxy: c.sts_http_proxy, endpoint: c.sts_endpoint_url)
                                         end
        elsif c.sts_http_proxy
          credentials_options[:client] = if iam_user_credentials
                                           Aws::STS::Client.new(region: region, http_proxy: c.sts_http_proxy, credentials: iam_user_credentials)
                                         else
                                           Aws::STS::Client.new(region: region, http_proxy: c.sts_http_proxy)
                                         end
        elsif c.sts_endpoint_url
          credentials_options[:client] = if iam_user_credentials
                                           Aws::STS::Client.new(region: region, endpoint: c.sts_endpoint_url, credentials: iam_user_credentials)
                                         else
                                           Aws::STS::Client.new(region: region, endpoint: c.sts_endpoint_url)
                                         end
        else
          credentials_options[:client] = if iam_user_credentials
                                           Aws::STS::Client.new(region: region, credentials: iam_user_credentials)
                                         else
                                           Aws::STS::Client.new(region: region)
                                         end
        end

        options[:credentials] = Aws::AssumeRoleCredentials.new(credentials_options)
      elsif @aws_key_id && @aws_sec_key
        options[:access_key_id] = @aws_key_id
        options[:secret_access_key] = @aws_sec_key
      elsif @web_identity_credentials
        c = @web_identity_credentials
        credentials_options[:role_arn] = c.role_arn
        credentials_options[:role_session_name] = c.role_session_name
        credentials_options[:web_identity_token_file] = c.web_identity_token_file
        credentials_options[:policy] = c.policy if c.policy
        credentials_options[:duration_seconds] = c.duration_seconds if c.duration_seconds
        if c.sts_region
          credentials_options[:client] = Aws::STS::Client.new(region: c.sts_region)
        elsif @aws_region
          credentials_options[:client] = Aws::STS::Client.new(region: @aws_region)
        end
        options[:credentials] = Aws::AssumeRoleWebIdentityCredentials.new(credentials_options)
      elsif @instance_profile_credentials
        c = @instance_profile_credentials
        credentials_options[:retries] = c.retries if c.retries
        credentials_options[:ip_address] = c.ip_address if c.ip_address
        credentials_options[:port] = c.port if c.port
        credentials_options[:http_open_timeout] = c.http_open_timeout if c.http_open_timeout
        credentials_options[:http_read_timeout] = c.http_read_timeout if c.http_read_timeout
        options[:credentials] = if ENV['AWS_CONTAINER_CREDENTIALS_RELATIVE_URI']
                                  Aws::ECSCredentials.new(credentials_options)
                                else
                                  Aws::InstanceProfileCredentials.new(credentials_options)
                                end
      elsif @shared_credentials
        c = @shared_credentials
        credentials_options[:path] = c.path if c.path
        credentials_options[:profile_name] = c.profile_name if c.profile_name
        options[:credentials] = Aws::SharedCredentials.new(credentials_options)
      elsif @aws_iam_retries
        log.warn("'aws_iam_retries' parameter is deprecated. Use 'instance_profile_credentials' instead")
        credentials_options[:retries] = @aws_iam_retries
        options[:credentials] = if ENV['AWS_CONTAINER_CREDENTIALS_RELATIVE_URI']
                                  Aws::ECSCredentials.new(credentials_options)
                                else
                                  Aws::InstanceProfileCredentials.new(credentials_options)
                                end
      end
      options
    end

    def send_event_to_eventbridge(event_params)
      @eventbridge.put_events(
        entries: [
          {
            source: event_params[:source],
            detail_type: event_params[:detail_type],
            time: event_params[:time],
            detail: event_params[:detail],
            event_bus_name: @event_bus_name
          }
        ]
      )
    rescue StandardError => e
      log.error("Failed to send event to EventBridge: #{e.message}")
    end
  end
end
