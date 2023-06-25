# Test

## Create EventBridge Bus and Rule

Create resource in your AWS account. Ex: bus name: test / region: ap-northeast-1

## IAM permission

create IAM role or user, here is the sample of env file

```
AWS_REGION=ap-northeast-1
AWS_ACCESS_KEY_ID=XXXXXXX
AWS_SECRET_ACCESS_KEY=XXXXXXX
AWS_SESSION_TOKEN=XXXXXXXXX
AWS_SECURITY_TOKEN=XXXXXXXXX
```


## Build and Run

run docker compose and edit the fluent.conf for more detail

```
docker-compose build
docker-compose up -d
```


## Inject sample

In this example, we create HTTP API input and output to both stdout and eventbridge.

```
curl -H 'content-type: application/json' -d '{"event_type":"subscribe", "source": "store", "data": "test payload"}' -XPOST http://localhost:9880/event
```
