module ArTranslate
  class TranslatedColumn
    KEYWORDS = %w(attributes languages)

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

    def check_plural_name!
      return if column.pluralize == column
      return if column.singularize != column

      fail Error, "Column name #{column} is not pluralized"
    end

    def check_languages!
      if !langs.is_a?(Array) || langs.empty?
        fail Error, "No languages specified for column #{column}"
      end

      langs.each do |lang|
        next if lang =~ /^[a-z]+$/ && !KEYWORDS.include?(lang)
        fail Error, "Invalid language '#{lang}' (should be lowercase only)"
      end
    end

    def model_method(name, &block)
      method_name = "#{prefix}_#{name}"
      c_column = column

      model.instance_eval do
        define_method(method_name) do |*args|
          column_info = self.class.columns_hash[c_column]
          fail Error, "Invalid column #{c_column}" if column_info.nil?
          fail Error, "Column type for #{c_column} is not hstore" unless column_info.type == :hstore

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
    end

    def define_languages
      c_langs = langs
      model_method(:languages) { c_langs }
    end
  end
end
