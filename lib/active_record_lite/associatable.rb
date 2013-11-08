require 'active_support/core_ext/object/try'
require 'active_support/inflector'
require_relative './db_connection.rb'

class AssocParams
  def self.my_attr_accessor(*attributes)
		# For each attribute name
		attributes.each do |attr_name|
			instance_var_sym = "@#{attr_name}".to_sym

			# Create getter
			define_method(attr_name) do
				instance_variable_get(instance_var_sym)
			end

			# Create setter
			define_method("#{attr_name}=") do |value|
				instance_variable_set(instance_var_sym, value)
			end
		end
  end

  def other_class
    @other_class_name.to_s.capitalize.constantize
  end

  def other_table
    other_class.table_name
  end

end

class BelongsToAssocParams < AssocParams
  my_attr_accessor :name, :other_class_name, :primary_key, :foreign_key

  def initialize(name, params)
    @name = name

    default = {
      class_name: name.to_s.camelcase,
      foreign_key: "#{name}_id",
      primary_key: "id"
    }

    params = default.merge(params)

    @other_class_name = params[:class_name]
    @foreign_key = params[:foreign_key]
    @primary_key = params[:primary_key]
  end

  def type
  end
end

class HasManyAssocParams < AssocParams
  my_attr_accessor :name, :other_class_name, :primary_key, :foreign_key

  def initialize(name, params, self_class)
    @name = name

    default = {
      class_name: name.to_s.singularize.camelcase,
      foreign_key: "#{self_class.to_s.underscore}_id",
      primary_key: "id"
    }

    params = default.merge(params)

    @other_class_name = params[:class_name]
    @foreign_key = params[:foreign_key]
    @primary_key = params[:primary_key]
  end

  def type
  end
end

module Associatable
  def assoc_params
  end

  def belongs_to(name, params = {})

    define_method(name) do
      btap = BelongsToAssocParams.new(name, params)

      query = <<-SQL
      SELECT
        ot.*
      FROM
        #{btap.other_table} ot
      JOIN
        #{self.class.table_name} t
      ON
        t.#{btap.foreign_key} = ot.#{btap.primary_key}
      WHERE
        t.id = ?
      SQL

      results = DBConnection.execute(query, self.id)

      btap.other_class.parse_all(results).first

    end
  end

  def has_many(name, params = {})
    define_method(name) do
      hmap = HasManyAssocParams.new(name, params, self.class)

      query = <<-SQL
      SELECT
        ot.*
      FROM
        #{hmap.other_table} ot
      JOIN
        #{self.class.table_name} t
      ON
        t.#{hmap.primary_key} = ot.#{hmap.foreign_key}
      WHERE
        t.id = ?
      SQL

      results = DBConnection.execute(query, self.id)

      hmap.other_class.parse_all(results)

    end
  end

  def has_one_through(name, assoc1, assoc2)
  end
end
