# frozen_string_literal: true
class Post < ActiveRecord::Base
  extend ArTranslate

  translates :names, languages: %w(de en)

  name_attributes.each do |attr|
    validates attr, length: { in: 2..200 }
  end
end
