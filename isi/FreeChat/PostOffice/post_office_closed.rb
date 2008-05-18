module Isi
  module FreeChat
    module PostOffice
      require ModuleRootDir + 'post_office_exception'
      class PostOfficeClosed < PostOfficeException
      end
    end
  end
end
