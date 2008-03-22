module RandomStuff
	require 'socket'
	def self.find_openssl_classes
		result = []
		ObjectSpace.each_object(Class) { |klass|
			result << klass if klass.name =~ /Object/
        }
		return result
    end
    
    require 'resolv'
    def self.resolv_tests
      addresses = ['127.0.0.1']
      names = ['localhost']
      methods = [:each_address, :each_name]
      block = proc { |a| puts "    - #{a.inspect}" }
      p(Resolv::IPv4.create(addresses.first))
      for method in methods do
        puts "#{method} :: checking addresses"
        for address in addresses do
          puts " - #{address}"
          Resolv.send(method, address, &block)
        end
        puts "#{method} :: checking names"
        for name in names do begin
          puts " - #{name}"
          Resolv.send(method, name, &block)
        rescue Exception => e
          puts " +++ #{e}"
        end end
      end
    end
    
    def self.arrys
      for o in [(1..5), 'asdas', 123, {2=>4, 5=>6}, [1,6,0], nil] do
        p o
        begin p o.to_a
        rescue NoMethodError => e
          puts 'No #to_a'
        end
        begin p o.to_ary
        rescue NoMethodError => e
          puts 'No #to_ary'
        end
      end
    end
end

RandomStuff::arrys