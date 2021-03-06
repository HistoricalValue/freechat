module Isi
  module FreeChat
    module BuddyBook
      Isi::db_hello __FILE__, name
      
      ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
      
      # require all files for this module
      reqs = ['buddy_entry', 'buddy_book']
      for r in reqs do require ModuleRootDir + r end
      
      Isi::db_bye __FILE__, name
    end
  end
end
