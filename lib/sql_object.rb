require_relative 'db_connection'
require_relative 'associatable'
require 'active_support/inflector'

class SQLObject
  extend Associatable

  def self.columns
    columns = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    columns.first.map do |column|
      column.to_sym
    end
  end

  def self.finalize!
    self.columns.each do |column|
      setter = "#{column}="

      define_method(column) do
        @attributes[column]
      end

      define_method(setter) do |arg|
        @attributes[column] = arg
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    unless @table_name
      self.table_name = self.to_s.tableize
    else
      @table_name
    end
  end

  def self.all
    results = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL

    parse_all(results)
  end

  def self.parse_all(results)
    results.map do |hash|
      self.new(hash)
    end
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL

    return nil if results.empty?
    self.new(results.first)
  end

  def initialize(params = {})
    @attributes = {}

    params.each do |method_name, value|
      raise "unknown attribute '#{method_name}'" unless self.class.columns.include?(method_name.to_sym)

      self.send("#{method_name}=", value)
    end

  end

  def attributes
    @attributes
  end

  def attribute_values
    self.class.columns.map do |attribute|
      self.send(attribute)
    end
  end

  def insert
    cols = self.class.columns
    col_names = cols.join(", ")
    question_marks = ["?"] * cols.length
    question_marks = question_marks.join(", ")

    DBConnection.execute(<<-SQL, *self.attribute_values)
      INSERT INTO
        #{self.class.table_name} (#{col_names})
      VALUES
        (#{question_marks})
    SQL

    self.id = DBConnection.last_insert_row_id
  end

  def update
    col_names = self.class.columns[1..-1].join(" = ?, ") + (" = ?")

    DBConnection.execute(<<-SQL, *self.attribute_values.rotate)
      UPDATE
        #{self.class.table_name}
      SET
        #{col_names}
      WHERE
        id = ?
    SQL
  end

  def save
    if id
      self.update
    else
      self.insert
    end
  end
end
