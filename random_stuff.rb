module RandomStuff
    $isi= {}
    require 'trunk/isi/freechat'
    
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
    
    def self.paths?
      meths=[]
      for ancestor in ancestors do
        meths += ancestor.instance_methods
      end
      meths += instance_methods
      meths.sort!
      p(meths.grep(/pa/))
    end
    
    module Hihi
      A_Const = '134'
    end
    def self.private_const
      ms = Hihi.methods.sort
      puts(ms.grep(/const/))
    end
    
    def self.post_office_test
      addr = Isi::FreeChat::PostOffice::Address.new '127.0.0.1', 12000
      po = Isi::FreeChat::PostOffice::PostOffice.new addr
      sleep 5
      po.send_to(addr, 'deth')
      po.close_down
    end
    
    def self.lambdas
      ps = [
        lambda { |i| return i },
        #Proc.new { |i| return i}
      ]
      for p in ps do begin
        lanal(&p)
        puts 'here'
      rescue => e then
        puts e
      end end
      #lanal { |i| return i}
      lanal do |i| return i end
      puts 'here'
    end
    
    def self.lanal(&block)
      puts "Analysing: #{block.inspect}"
      block.call 1,2,3,4
    end
end
RandomStuff::post_office_test