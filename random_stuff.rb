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
end
