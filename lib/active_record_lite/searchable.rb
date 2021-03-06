require_relative './db_connection'

module Searchable
  # takes a hash like { :attr_name => :search_val1, :attr_name2 => :search_val2 }
  # map the keys of params to an array of  "#{key} = ?" to go in WHERE clause.
  # Hash#values will be helpful here.
  # returns an array of objects
  def where(params)
    #p params.values.join(", ")
    where_clause = params.keys.map do |key|
      "#{key} = ?"
    end.join(", AND ")
    p where_clause
    p params.values.join(", ")
    DBConnection.execute(<<-SQL, Breakfest)
    SELECT
    *
    WHERE
      #{where_clause}
    SQL
  end
end