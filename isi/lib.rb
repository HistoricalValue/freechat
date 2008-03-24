module Isi
  # Custom modification and additions to standard Ruby classes and modules
  
  class ::Object
    def to_b; if self then true else false end end
  end
  
  # saying hello and bye in module loading
  def self.db_hello filename, modulename=nil
    puts "#{filename} :: <#{modulename}> hello" if $isi and $isi[:debug_hello]
  end
  def self.db_bye filename, modulename=nil
    puts "#{filename} :: <#{modulename}> bye" if $isi and $isi[:debug_bye]
  end
  
  # turning Integers into arrays of bytes and back
  class ::Integer
    # Returns a list of bytes representing this number.
    # result.first is the Least Signigicant Byte and
    # result.last is the Most Significant Byte.
    def bytes
      num = self
      result = []
      while not num.zero?
        result << (num & 0xff)
        num = num >> 8
      end
      return result
    end

    # Creates a new Integer from the given byte array.
    # bytes.first must be LSB and bytes.last MSB.
    # Throws an ArgumentError for an empty array.
    def self.from_bytes bytes=[0]
      raise ArgumentError.new('Empty array of bytes') if bytes.empty?
      result = 0
      bytes.each_with_index do |byte, index|
        result += byte << index * 8
      end
      return result
    end
  end

end