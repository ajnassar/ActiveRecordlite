class MassObject
  # takes a list of attributes.
  # adds attributes to whitelist.
  def self.my_attr_accessible(*attributes)
    #raise "mass assignment to unregistered attribute not_protected" if
    @attributes = []
    @attributes.concat(attributes)
  end

  # takes a list of attributes.
  # makes getters and setters
  def self.my_attr_accessor(*attributes)
    attributes.each do |attribute|
      define_method(attribute) do
        instance_variable_get("@#{attribute}")
      end

      define_method("#{attribute}=") do |value|
        instance_variable_set("@#{attribute}", value )
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
    hashes = []
    results.each do |hash|
      hashes << self.new(hash)
    end
    hashes
  end

  # takes a hash of { attr_name => attr_val }.
  # checks the whitelist.
  # if the key (attr_name) is in the whitelist, the value (attr_val)
  # is assigned to the instance variable.
  def initialize(params = {})
   params.each do |attr_name, value|
     if self.class.attributes.include?(attr_name.to_sym)
       send("#{attr_name}=", value)
     else
       raise "mass assignment to unregistered attribute #{attr_name}"
     end
    end
  end
end
