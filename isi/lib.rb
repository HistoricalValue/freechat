module Isi
  # Custom modification and additions to standard Ruby classes and modules
  
  class Object
    def to_b; if self then true else false end end
  end
  
end