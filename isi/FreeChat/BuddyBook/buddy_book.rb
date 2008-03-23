module Isi
  module FreeChat
    module BuddyBook
      class BuddyBook
        Isi::db_hello __FILE__, name
        
        ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
        
        def initialize
          
        end
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
