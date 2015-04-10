require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = []
    values = []

    params.each do |key, value|
      where_line << (key.to_s + " = ?")
      values << value
    end

    where_line = where_line.join(" AND ")

    results = DBConnection.execute(<<-SQL, *values)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL

    results.map do |result|
      self.new(result)
    end
  end
end

class SQLObject
  extend Searchable
end
