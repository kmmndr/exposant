# Exposant

In a Rails application, it is often required to fill a gap between Models and
Views. There are of course, many differents ways to fill this gap, one of these
is exhibitors (or improved decorators).

This gem provide an easy way to create Ruby exhibitors or decorators.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'exposant'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install exposant

## Usage

There are two kinds of exhibitors refering to model or collection.

A collection exhibitor is meant to encapsulate an enumerable object (like
ActiveRecord Relation or just Array). It overrides `each` method to ensure
encapsulation of resulting objects.

A model exhibitor improve it's associated object, like adding non-database
related methods to an ActiveRecord object for example.

To use this gem in a Rails application, create a folder `app/exhibitors`.
Create pluralized exhibitors for collections and singularized exhibitors for
models.

### Example:

Consider having a User model with `first_name` and `last_name`

```ruby
# app/models/application_record.rb
class ApplicationRecord < ActiveRecord::Base
  include Exposant::Exposable
end

# app/exhibitors/user_exhibitor.rb
class UserExhibitor < Exposant::ModelExhibitor
  def full_name
    "#{first_name} #{last_name}"
  end
end

# app/exhibitors/users_exhibitor.rb
class UsersExhibitor < Exposant::CollectionExhibitor
  # You can add methods for collections too if necessary
end
```

Then you may want to use your brand new exhibitor in your controller
```ruby
# app/controllers/users_controller.rb
class UsersController < DefaultController
  def index
    @users = User.exhibitor(User.all)
  end

  def show
    @user = User.find(...).exhibitor
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kmmndr/exposant.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
