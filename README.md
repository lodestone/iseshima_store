# IseshimaStore :dolls:

Simple ruby ORM for Google Cloud Datastore.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'iseshima_store'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install iseshima_store

## Usage

### Setup

You need to set project_id.

```
IseshimaStore::Connection.configure do |config|
  config.project_id = 'xxxx'
end
```

Iseshima Store depends on `gcloud-ruby` which uses ENV variables, you can set your variables through ENV.

### Model

```
class User
  include IseshimaStore::Base
  attr_accessor :name, :email
end
```

The only thing you have to do is just include `IseshimaStore::Base` in your model class.
Any class is ok to use.

### Create

```
user = User.new
user.email = 'test@test.com'
user.name = 'hoge@fuga.com'
user.save!
```

IseshimaStore does not have validations. 
Another gem like `ActiveModel` is recommended to combine.

### Finder

```
users = User.where(email: 'test@test.com')
user = User.find_by(email: 'test@test.com')
user = User.find(12345) # id
```

### Low level search

```
query = Gcloud::Datastore::Query.new
query.kind('User')
query.where('email', '=', 'test@test.com')
res = User.search(query: query)
users = res[:records]
```

If you need `limit` & `cursor`, use this API.




## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

