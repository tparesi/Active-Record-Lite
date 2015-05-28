require_relative 'assoc_options'

module Associatable

  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options

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
    @assoc_options_hash ||= {}
  end


  def has_one_through(name, through_name, source_name)

    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]

      through_table = through_options.table_name
      through_fk = through_options.options[:foreign_key]
      through_pk = through_options.options[:primary_key]

      source_table = source_options.table_name
      source_fk = source_options.options[:foreign_key]
      source_pk = source_options.options[:primary_key]

      through_fk_num = self.send(through_fk)
      results = DBConnection.execute(<<-SQL, through_fk_num)
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_fk} = #{source_table}.#{source_pk}
        WHERE
          #{through_table}.#{through_pk} = ?
      SQL

      source_options.model_class.parse_all(results).first
    end
  end
end
