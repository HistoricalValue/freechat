module Isi
  module FreeChat
    module Protocol
      module MessageCentre
        require ModuleRootDir + 'message_centre_exception'
        class MessageArgumentException < MessageCentreException
        end
      end
    end
  end
end
