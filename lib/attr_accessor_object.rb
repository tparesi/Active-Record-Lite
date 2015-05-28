class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      name_sym = ('@' + name.to_s).to_sym
      setter = "#{name}="

      define_method(name) do
        self.instance_variable_get(name_sym)
      end


      define_method(setter) do |arg|
        self.instance_variable_set(name_sym, arg)
      end
    end
  end
end
