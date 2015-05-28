require_relative 'searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  attr_reader :name, :options

  def initialize(name, options = {})
    @name = name
    defaults = {
      class_name: "#{name.to_s.camelcase}",
      foreign_key: "#{name}_id".to_sym,
      primary_key: :id
    }

    @options = defaults.merge(options)

    @options.each do |key, value|
      self.send("#{key}=", value)
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @name = name
    defaults = {
      class_name: "#{name.to_s.singularize.camelcase}",
      foreign_key: "#{self_class_name.to_s.underscore}_id".to_sym,
      primary_key: :id
    }

    @options = defaults.merge(options)

    @options.each do |key, value|
      self.send("#{key}=", value)
    end
  end
end
