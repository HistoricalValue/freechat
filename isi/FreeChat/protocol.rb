module Isi  
  module FreeChat
    module Protocol
      Isi::db_hello __FILE__, name
      
      ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
      
      # require all files for this module
      # ---
      # Required modules in Isi::FreeChat
      freechat_reqs = ['buddy_book', 'post_office']
      for freechat_r in freechat_reqs do 
        require FreeChat::ModuleRootDir + freechat_r
      end
      # Required modules in this module
      reqs = ['linker', 'message_centre']
      for r in reqs do
        require ModuleRootDir + r
      end
      
      Isi::db_bye __FILE__, name
    end
  end
end
