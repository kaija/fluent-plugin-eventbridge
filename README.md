# Amazon EventBridge input and output plugin for Fluentd


## Installation

### RubyGems

```
$ gem install fluent-plugin-eventbridge
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-eventbridge"
```

And then execute:

```
$ bundle
```

## Configuration

## Fluent::Plugin::AwsEventBridgeOutput

### aws_key_id (string) (optional)



### aws_sec_key (string) (optional)

AWS secret key.

### aws_region (string) (optional)



Default value: `ap-northeast-1`.

### event_bus_name (string) (optional)



Default value: `default`.

### batch_size (integer) (optional)



Default value: `15`.

### source_key (string) (optional)



Default value: `source`.

### detail_type_key (string) (optional)



Default value: `event_type`.

### time_key (string) (optional)



Default value: `time`.


### \<assume_role_credentials\> section (optional) (single)

#### role_arn (string) (required)

The Amazon Resource Name (ARN) of the role to assume

#### role_session_name (string) (required)

An identifier for the assumed role session

#### policy (string) (optional)

An IAM policy in JSON format

#### duration_seconds (integer) (optional)

The duration, in seconds, of the role session (900-3600)

#### external_id (string) (optional)

A unique identifier that is used by third parties when assuming roles in their customers' accounts.

#### sts_region (string) (optional)

The region of the STS endpoint to use.

#### sts_http_proxy (string) (optional)

A http proxy url for requests to aws sts service

#### sts_endpoint_url (string) (optional)

A url for a regional sts api endpoint, the default is global



### \<web_identity_credentials\> section (optional) (single)

#### role_arn (string) (required)

The Amazon Resource Name (ARN) of the role to assume

#### role_session_name (string) (required)

An identifier for the assumed role session

#### web_identity_token_file (string) (required)

The absolute path to the file on disk containing the OIDC token

#### policy (string) (optional)

An IAM policy in JSON format

#### duration_seconds (integer) (optional)

The duration, in seconds, of the role session (900-43200)

#### sts_region (string) (optional)

The region of the STS endpoint to use.



### \<instance_profile_credentials\> section (optional) (single)

#### retries (integer) (optional)

Number of times to retry when retrieving credentials

#### ip_address (string) (optional)

IP address (default:169.254.169.254)

#### port (integer) (optional)

Port number (default:80)

#### http_open_timeout (float) (optional)

Number of seconds to wait for the connection to open

#### http_read_timeout (float) (optional)

Number of seconds to wait for one block to be read



### \<shared_credentials\> section (optional) (single)

#### path (string) (optional)

Path to the shared file. (default: $HOME/.aws/credentials)

#### profile_name (string) (optional)

Profile name. Default to 'default' or ENV['AWS_PROFILE']

## Copyright

* Copyright(c) 2023- kaija
* License
  * Apache License, Version 2.0
