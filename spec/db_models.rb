Object.__send__(:remove_const, :Post) if defined?(Post)

class Post < ActiveRecord::Base
  extend ArTranslate

  translates :names, languages: %w(de en)

  name_attributes.each do |attr|
    validates attr, length: { in: 2..200 }
  end
end
