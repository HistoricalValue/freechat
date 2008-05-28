module Isi
  module FreeChatUI
    Isi::db_hello __FILE__, name
    
    require 'pathname'
    ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
    
    require ModuleRootDir + 'j_ui_communicator'
    # require all files required by this module
    Isi::db_bye __FILE__, name
  end
end
