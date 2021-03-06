require_relative './associatable'
require_relative './db_connection' # use DBConnection.execute freely here.
require_relative './mass_object'
require_relative './searchable'

class SQLObject < MassObject

  extend Searchable
  extend Associatable

  # sets the table_name
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
    results = DBConnection.execute("SELECT * FROM #{self.table_name}")

    self.parse_all(results)
  end

  # querys database for record of this type with id passed.
  # returns either a single object or nil.
  def self.find(id)
    results = DBConnection.execute("SELECT * FROM #{self.table_name} WHERE id = ?", id)

    self.parse_all(results).first
  end

  # executes query that creates record in db with objects attribute values.
  # use send and map to get instance values.
  # after, update the id attribute with the helper method from db_connection
  def create
    comma_sep_attr_names = self.class.attributes.map(&:to_s).join(',')
    question_marks = (['?']*self.class.attributes.count).join(', ')

    query = "INSERT INTO #{self.class.table_name} (#{comma_sep_attr_names}) VALUES (#{question_marks})"

    attr_values = self.class.attributes.map do |attr_name|
      self.send(attr_name)
    end

    DBConnection.execute(query, *attr_values)

    self.id = DBConnection.last_insert_row_id
  end

  # executes query that updates the row in the db corresponding to this instance
  # of the class. use "#{attr_name} = ?" and join with ', ' for set string.
  def update
    assignments = self.class.attributes.map do |attr_name|
      "#{attr_name} = ?"
    end.join(', ')

    query = "UPDATE #{self.class.table_name} SET #{assignments} WHERE id = ?"

    attr_values = self.class.attributes.map do |attr_name|
      self.send(attr_name)
    end

    DBConnection.execute(query, *attr_values, self.id)
  end

  # call either create or update depending if id is nil.
  def save
    if self.id.nil? #create
      self.create
    else # update
      self.update
    end
  end

  # helper method to return values of the attributes.
  def attribute_values
  end
end
