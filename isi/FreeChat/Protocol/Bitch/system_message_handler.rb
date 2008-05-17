module Isi
  module FreeChat
    module Protocol
      module Bitch
        require ModuleRootDir + 'message_handler'
        class SystemMessageHandler < MessageHandler
          def message_received addr, msg
            bitch.ui.g(bitch.link.get_buddy_using_address(addr),
                FreeChatUI::INFO, bitch.mc.message_to_s(msg))
          end
        end
      end
    end
  end
end
