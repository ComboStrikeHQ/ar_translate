Object.send(:remove_const, :Post) if defined?(Post)

class Post < ActiveRecord::Base
  extend ArTranslate

  translates :names, languages: %w(de en)
end
