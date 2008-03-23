module Isi
  # Custom modification and additions to standard Ruby classes and modules
  
  class Object
    def to_b; if self then true else false end end
  end
  
  # saying hello and bye in module loading
  def self.db_hello filename, modulename=nil
    puts "#{filename} :: <#{modulename}> hello" if $isi and $isi[:debug_hello]
  end
  def self.db_bye filename, modulename=nil
    puts "#{filename} :: <#{modulename}> bye" if $isi and $isi[:debug_bye]
  end
end