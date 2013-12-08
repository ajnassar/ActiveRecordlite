require_relative './associatable'
require_relative './db_connection' # use DBConnection.execute freely here.
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject
  extend Searchable
  # sets the table_name
  # my_attr_accessor :table_name
  def self.set_table_name(table_name)
    @table_name = table_name
  end

  # gets the table_name
  def self.table_name
    @table_name
  end

  # querys database for all records for this type. (result is array of hashes)
  # converts resulting array of hashes to an array of objects by calling ::new
  # for each row in the result. (might want to call #to_sym on keys)
  def self.all
    self.parse_all(
      DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
         #{self.table_name}
      SQL
    )

  end

  # querys database for record of this type with id passed.
  # returns either a single object or nil.
  def self.find(id)
    found_column = DBConnection.execute(<<-SQL, :id => id)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      id = :id
    SQL
    return nil if found_column == []
    self.new(found_column.first)
  end

  # executes query that creates record in db with objects attribute values.
  # use send and map to get instance values.
  # after, update the id attribute with the helper method from db_connection
  def create
    attribute_names = self.class.attributes[1..-1].join(", ")
    attribute_values = self.class.attributes[1..-1].map do |attribute|
      "'#{send(attribute)}'"
    end.join(", ")
    DBConnection.execute(<<-SQL)
    INSERT INTO
      #{self.class.table_name} (#{attribute_names})
    VALUES
      (#{attribute_values})
    SQL
  end

  # executes query that updates the row in the db corresponding to this instance
  # of the class. use "#{attr_name} = ?" and join with ', ' for set string.
  def update
    attribute_names = self.class.attributes[1..-1]
    attribute_values = self.class.attributes[1..-1].map do |attribute|
      "'#{send(attribute)}'"
    end
    i = 0
    set_array = []
    attribute_names.each do |name|
      set_array << "#{name} = #{attribute_values[i]}"
      i+=1
    end
    set = "SET " + set_array.join(", ")
    DBConnection.execute(<<-SQL, :id => id)
      UPDATE
        #{self.class.table_name} #{set}
      WHERE
        :id = id
      SQL
  end

  # call either create or update depending if id is nil.
  def save
    if self.id == nil
      create
    else
      update
    end
  end

  # helper method to return values of the attributes.
  def attribute_values
  end
end
