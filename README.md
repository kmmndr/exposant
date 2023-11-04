# Exposant

In a Rails application, it is often required to fill a gap between Models and
Views. There are of course, many differents ways to fill this gap, one of these
is decorators and its variants exhibits or presenters.

The main difference between decorators, exhibits and presenters are their
proximity with the rendering layer. Typically a decorator is not meant to be
contextualized, whereas an exhibit is intended to have access to rendering
context.

This gem provide an easy way to create theese concepts in Ruby.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'exposant'
```

And then execute:

```ruby
$ bundle install
```

Or install it yourself as:

```
$ gem install exposant
```

## Usage

Exposant objects are intended to overload class (scopes) and instance methods
of any other object. The default type is exposant, choosing between decorator,
exhibit or any other type name is up to you. There is no magic involved for the
context, you just have to call contextualize and provide the required context.

### Basic example

Consider having a User model with `first_name` and `last_name`

```ruby
# app/models/user.rb
class User < ActiveRecord::Base
  include Exposant::Model
  has_exposant type: :decorator
end

# app/decorators/user_decorator.rb
class UserDecorator < Exposant::Base
  def full_name
    "#{first_name} #{last_name}"
  end
end
```

Then you may want to use your brand new decorator in your controller

```ruby
# app/controllers/users_controller.rb
class UsersController < DefaultController
  def index
    @users = User.decorator(User.all)
  end

  def show
    @user = User.find(...).decorator
  end
end
```

### Contextualization example

If you want to contextualize a presenter, for example in a Rails application.

```ruby
# app/controllers/users_controller.rb
class UsersController < DefaultController
  def index
    @users = User.presenter(User.all)
    @users.contextualize(self)
  end

  def show
    @user = User.find(...).presenter
    @user.contextualize(self)
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can
also run `bin/console` for an interactive prompt that will allow you to
experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/kmmndr/exposant.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).
