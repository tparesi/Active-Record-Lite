require_relative '02_searchable'
require 'active_support/inflector'
require 'byebug'

# Phase IIIa
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
  def initialize(name, options = {})
    @name = name
    defaults = {
      class_name: "#{name.to_s.camelcase}",
      foreign_key: "#{name}_id".to_sym,
      primary_key: :id
    }

    options = defaults.merge(options)

    options.each do |key, value|
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

    options = defaults.merge(options)

    options.each do |key, value|
      self.send("#{key}=", value)
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      foreign_key_name = options.send(:foreign_key)
      foreign_key = send(foreign_key_name)
      class_name = options.model_class

      results = class_name.where({ id: foreign_key })

      results.first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)

    define_method(name) do
      class_name = options.model_class
      foreign_key = options.send(:foreign_key)

      class_name.where({ foreign_key => self.id })
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.

    @assoc_options_hash = {}
  end
end

class SQLObject
  extend Associatable
end
