# ArTranslate

[![Circle CI](https://circleci.com/gh/ad2games/ar_translate.svg?style=svg)](https://circleci.com/gh/ad2games/ar_translate)
[![Code Climate](https://codeclimate.com/github/ad2games/ar_translate/badges/gpa.svg)](https://codeclimate.com/github/ad2games/ar_translate)
[![Test Coverage](https://codeclimate.com/github/ad2games/ar_translate/badges/coverage.svg)](https://codeclimate.com/github/ad2games/ar_translate/coverage)

Store values for multiple languages in an ActiveRecord attribute using PostgreSQL's hstore.

## Installation

Add the gem to your application's Gemfile:

```ruby
gem 'ar_translate'
```

## Usage

Create a hstore column of the pluralized attribute name:
```ruby
add_column :posts, :descriptions, :hstore
```

Add the following to your model:
```ruby
class Post < ActiveRecord::Base
  extend ArTranslate

  translates :descriptions, languages: %w(de en es)
end
```

Now you have access to the following methods:

```ruby
post = Post.new

post.description_de = 'Hallo wie geht es dir?'
post.description_en = 'Whats up?'

post.descriptions
# => { 'de' => 'Hallo wie geht es dir?', 'en' => 'Whats up?' }

post.description_de
# => 'Hallo wie geht es dir?'

post.description_languages
# => ['de', 'en', 'es']

post.description_attributes
# => [:description_de, :description_en, :description_es]

# The two methods above also work at class level:
Post.description_languages # => [...]
Post.description_attributes # => [...]
```

This makes it really easy to use forms with translated attributes:
```ruby
= form_for @post do |f|
  = f.text_field :name
  - @post.description_attributes.each do |attr|
    = f.text_field attr
```

Or you can add validations to your model:
```ruby
class Post < ActiveRecord::Base
  extend ArTranslate

  translates :descriptions, languages: %w(de en es)

  description_attributes.each do |attr|
    validates attr, length: { in: 20..200 }
  end
end
```

## License

MIT, see LICENSE.txt

## Contributing

Feel free to fork and submit pull requests!

You need to set the `DATABASE_URL` environment variable
to a valid PostgreSQL database for testing.

```
$ createdb ar_translate_test
$ export DATABASE_URL="postgres://localhost/ar_translate_test"
$ bundle exec rspec
```
