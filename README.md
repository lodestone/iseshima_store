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

```ruby
IseshimaStore::Connection.configure do |config|
  config.project_id = 'xxxx'
end
```

Iseshima Store depends on `gcloud-ruby` which uses ENV variables, you can set your variables through ENV.

### Model

```ruby
class User
  include IseshimaStore::Base
  attr_properties :name, :email
end
```

The only thing you have to do is just 2 things.

1. include `IseshimaStore::Base` in your model class.
2. declare your properties with `attr_properties`

Any class is ok to use.

### Create

```ruby
user = User.new
user.email = 'taro@test.com'
user.name = 'taro'
user.save!
```

or

```ruby
User.new.assign_attributes(
  email: 'taro@test.com',
  name: 'taro'
).save!
```

### Save or Delete

```
# save
user = User.first
user.assign_attributes(email: 'taro@test.jp')
user.save!

# delete
user.destroy
```

IseshimaStore does not have validations.
Another gem like `ActiveModel` is recommended to combine.

### Finder

```ruby
users = User.where(email: 'test@test.com')
user = User.find_by(email: 'test@test.com')
user = User.find(12345) # id

# You can chain queries.
user = User.where(visible: true).find(10)
```

### Relation


```ruby
diary = Diary.new
diary.title = 'My nightmare'
diary.parent = user
diary.save!
```

`parent=(model)` sets model's key to the key's parent of instance.


### Low level search

```ruby
query = Gcloud::Datastore::Query.new
query.kind('User')
query.where('email', '=', 'test@test.com')
res = User.search(query: query)
users = res[:records]
```

If you need `limit` & `cursor`, use this API.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

