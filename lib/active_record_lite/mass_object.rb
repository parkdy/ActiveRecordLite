class MassObject
  # takes a list of attributes.
  # creates getters and setters.
  # adds attributes to whitelist.
  def self.my_attr_accessible(*attributes)
    @attributes = []
    attributes.each do |attribute|
      @attributes << attribute
    end

    # Create getters and setters
    my_attr_accessor(*attributes)
  end

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

  # returns list of attributes that have been whitelisted.
  def self.attributes
    @attributes
  end

  # takes an array of hashes.
  # returns array of objects.
  def self.parse_all(results)
    objects = []
    results.each do |result|
      objects << self.new(result)
    end
    objects
  end

  # takes a hash of { attr_name => attr_val }.
  # checks the whitelist.
  # if the key (attr_name) is in the whitelist, the value (attr_val)
  # is assigned to the instance variable.
  def initialize(params = {})
    params.each do |attr_name, value|
      if self.class.attributes.include?(attr_name.to_sym)
        self.send("#{attr_name}=".to_s, value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end
end