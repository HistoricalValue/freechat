module Isi
  # Custom modification and additions to standard Ruby classes and modules
  
  class ::Object
    def to_b; if self then true else false end end
  end
  
  # Returns the class whose name is specified as a string. If the argument
  # is not a string, it will be transformed to a string by +#to_s+ and then
  # used to find the class. If the argument is _nil_ then +Object+ is returned.
  def self.getClass class_name=nil
    return Object unless class_name
    class_name = class_name.to_s unless class_name.is_a?(String)
    family = class_name.split('::')
    result = Object
    for member in family
      result = result::const_get member
    end
    result
  end
  
  # SycnrhonizedValue provides synchronized access to a field
  class SynchronizedValue
    def initialize value
      @value = value
      @mutex = Mutex::new
    end

    def value
      @mutex.synchronize { @value }
    end

    def value= new_value
      @mutex.synchronize { @value = new_value }
    end
  end

  # saying hello and bye in module loading
  def self.db_hello filename, modulename=nil
    puts "#{filename} :: <#{modulename}> hello" if $isi and $isi[:debug_hello]
  end
  def self.db_bye filename, modulename=nil
    puts "#{filename} :: <#{modulename}> bye" if $isi and $isi[:debug_bye]
  end
  
  # Common end-of-line constant
  ENDL = ENV['LINESEPARATOR'] || ENV['LINE_SEPARATOR'] || "\n"

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
    # The argument *must* be an array.
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
    
    # (to binary string)
    # Returns a string representation of this Integer in binary format.
    # Optional argument "prefix" specifies whether the result should be
    # prefixed with "0b".
    def to_bs prefix=true
      "%#{'#' if prefix}b" % self
    end
    
    # (to hexadecimal string)
    # Returns a string representation of this Integer in hexadecimal format.
    # Optional argument "prefix" specifies whether the result should be
    # prefixed with "0x".
    def to_hs prefix=true
      "%#{'#' if prefix}x" % self
    end
  end
  
  class ::Array
    # Empty an array as by <code>a[0..a.length] = []</code>
    def empty!
      self[0..length-1] = []
    end
  end
  
  class ::String
    # Arguments _bytes_ must be something iterable. Returns a string to
    # which the bytes from the argument have been added in the order the
    # iterator returned them.
    def self.from_bytes(bytes)
      result = ''
      for byte in bytes do
        result << byte
      end
      return result
    end
  end
  
  # Often used functions
  Procs = {
    :to_s => lambda { |something_anything| something_anything.to_s }
  }
end