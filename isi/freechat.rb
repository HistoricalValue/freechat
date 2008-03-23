module Isi
  module FreeChat
    Isi::db_hello __FILE__, name
    
    require 'pathname'
    ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
    
    # require all files for this module
    require ModuleRootDir + 'protocol' # this should include everything else
    
    Isi::db_bye __FILE__, name
  end
end