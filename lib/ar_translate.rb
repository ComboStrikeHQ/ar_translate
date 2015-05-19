require 'active_record'
require 'active_support/inflector'
require 'ar_translate/version'
require 'ar_translate/error'
require 'ar_translate/translated_column'

module ArTranslate
  def translates(column, opts = {})
    TranslatedColumn.new(self, column, opts).inject
  end
end
