# Sejourn - 施錠しました

## Requirements

* Heroku CLI
* Postgres

## Setup

```
heroku config:set LINE_CHANNEL_SECRET=******
heroku config:set LINE_CHANNEL_TOKEN=******
heroku config:set SLACK_WEBHOOK_URL=******
```

## Deploy

```
git push heroku master
```

## Migrate

* デプロイ後にやる必要があるっぽい

```
heroku run rake db:migrate
```

## DB

* Heroku の管理画面に接続方法が載ってます
