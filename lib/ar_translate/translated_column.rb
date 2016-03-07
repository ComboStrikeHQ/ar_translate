# frozen_string_literal: true
module ArTranslate
  class TranslatedColumn
    KEYWORDS = %w(attributes languages).freeze

    attr_reader :model, :column, :langs

    def initialize(model, column, opts)
      @model = model
      @column = column.to_s
      @langs = opts.delete(:languages)

      check_plural_name!
      check_languages!
    end

    def inject
      define_attributes
      define_languages

      langs.each do |lang|
        define_reader(lang)
        define_writer(lang)
      end
    end

    private

    def prefix
      column.singularize
    end

    def attributes
      langs.map { |lang| :"#{prefix}_#{lang}" }
    end

    def langs
      @langs.map { |lang| lang.to_s.downcase }.uniq
    end

    def check_plural_name!
      return if column.pluralize == column && prefix != column && prefix.length > 0

      raise Error, "Column name #{column} is not pluralized"
    end

    def check_languages!
      if !@langs.is_a?(Array) || @langs.empty?
        raise Error, "No languages specified for column #{column}"
      end

      langs.each do |lang|
        next if lang =~ /^[a-z]+$/ && !KEYWORDS.include?(lang)
        raise Error, "Invalid language '#{lang}' (should be letters only)"
      end
    end

    def generate_column_type_checker(column)
      lambda do
        column_info = self.class.columns_hash[column]
        raise Error, "Invalid column #{column}" if column_info.nil?
        raise Error, "Column type for #{column} is not hstore" unless column_info.type == :hstore
      end
    end

    def model_method(name, &block)
      method_name = "#{prefix}_#{name}"
      check_column_type = generate_column_type_checker(column)

      model.instance_eval do
        define_method(method_name) do |*args|
          instance_exec(&check_column_type)
          instance_exec(*args, &block)
        end
      end
    end

    def model_class_method(name, &block)
      method_name = "#{prefix}_#{name}"

      model.instance_eval do
        define_singleton_method(method_name) do |*args|
          instance_exec(*args, &block)
        end
      end
    end

    def define_reader(lang)
      c_column = column
      model_method(lang) do
        self[c_column][lang]
      end
    end

    def define_writer(lang)
      c_column = column
      model_method("#{lang}=") do |val|
        self[c_column][lang] = val
      end
    end

    def define_attributes
      c_attributes = attributes
      model_method(:attributes) { c_attributes }
      model_class_method(:attributes) { c_attributes }
    end

    def define_languages
      c_langs = langs
      model_method(:languages) { c_langs }
      model_class_method(:languages) { c_langs }
    end
  end
end
