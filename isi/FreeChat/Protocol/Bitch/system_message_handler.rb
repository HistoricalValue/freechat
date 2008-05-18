module Isi
  module FreeChat
    module Protocol
      module Bitch
        require ModuleRootDir + 'message_handler'
        # Monolithic class for doing system-required handling of all
        # messages. Being monolithic is a bad idea. Will be split later.
        class SystemMessageHandler < MessageHandler
          include Isi::FreeChat::Protocol::MessageCentre::MessageTypes
          def message_received addr, msg
            case msg.type
            when STM_DELIVERY_SUCCESS then 
              if msg['rcp'] == bitch.id then
                bitch.mc.success msg['mid']
              else
                source = bitch.mc.source_of(msg['mid'])
                if source.nil?
                then # this means that this message was not forwarded through
                     # us but the delivery success is coming through us.
                     # Only thing we can do is send back a delivery failure
                     # message about the delivery success message
                     failure = bitch.mc.create_message(
                         STM_DELIVERY_FAILURE,
                         'mid' => msg.id,
                         'rcp' => bitch.link.get_buddy_using_address(addr)
                         )
                     bitch.po.send_to(addr, failure.serialise)
                else
                  bitch.po.send_to(bitch.link.get_address_of(source),
                      msg.serialise)
                  bitch.mc.expire(msg['mid'])
                end
              end
            end
          end
        end
      end
    end
  end
end
