# MailruApi

## Установка

Add this line to your application's Gemfile:

    gem 'mailru_api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mailru_api

## Использование

	client = ::MailruApi::Client.new app_id, api_secret, access_token
	client.stream.get_by_author 

