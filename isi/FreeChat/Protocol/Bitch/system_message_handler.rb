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
              if msg[RCP] == bitch.id then
                bitch.mc.success msg[MID]
              else
                source = bitch.mc.source_of(msg[MID])
                if source.nil?
                then # this means that this message was not forwarded through
                     # us but the delivery success is coming through us.
                     # Only thing we can do is send back a delivery failure
                     # message about the delivery success message
                     failure = bitch.mc.create_message(
                         STM_DELIVERY_FAILURE,
                         MID => msg.id,
                         RCP => bitch.link.get_buddy_using_address(addr)
                         )
                     bitch.po.send_to(addr, failure.serialise)
                else
                  bitch.po.send_to(bitch.link.get_address_of(source),
                      msg.serialise)
                  bitch.mc.expire(msg[MID])
                end
              end
            when STM_DELIVERY_FAILURE then
              if msg[RCP] == bitch.id then
                # A message we have sent has failed. Try to send again.
                mid = bitch.mc.failure msg[MID]
                # ignore this if we didn't send it
                unless mid.nil?
                # TODO reinitiate discovery for msg[MID]
                end
              else
                # supposed we forwarded the failed message at some point
                origin, mid = bitch.mc.failure msg[MID]
                # ignore if we didn't
                unless origin.nil? || mid.nil?
                  bitch.po.send_to(bitch.link.get_address_of(origin),
                      msg.serialise)
                  bitch.mc.expire(msg[MID])
                end
              end
            when STM_PRESENT then
              # Steal info eitherway...
              # TODO add correctly hops
              bitch.link.buddy_is_present(msg[BID],
                  bitch.link.get_buddy_using_address(addr))
              # Now send further if we must...
              if msg[RCP] != bitch.id && !bitch.mc.forwarded?(msg.id) then
                # forward
                bitch.mc.forward_message(msg)
              end
            when STM_GOODBYE
              # Tell linker
              bitch.link.buddy_goodbyed(msg[BID])
              # forward to all (unless we already have)
              unless bitch.mc.message_store.has_key?(msg.id)
                bitch.mc.message_store[msg.id] = nil
                sdata = msg.serialise
                bitch.link.present_buddies { |bid, mids|
                  bitch.po.send_to(bitch.link.get_address_of(mids.first[:mbid]),
                      sdata)
                }
              end
              # TODO deal with cut off buddies (Linker#cut_off_buddies)
            when STM_MESSAGE
              if msg[RCP] == bitch.id then
                bitch.ui.generic_message(msg[FRM], FreeChatUI::INFO, msg[CNT])
              else
                bitch.mc.forward_message(msg)
              end
            when STM_HELLO
              # if this is not about me...
              unless msg[BID] == bitch.id
                # Tell linker
                # TODO figure out hops correctly
                bitch.link.buddy_is_present(msg[BID],
                    bitch.link.get_buddy_using_address(addr))
                bitch.ui.b(FreeChatUI::FINER, "#{msg[BID]} is present (#{
                    bitch.mc.type_to_s msg})")
                # forward if not forwarded
                unless bitch.mc.message_store.has_key?(msg.id)
                  bitch.message_store[msg.id] = nil
                  sdata = msg.serialise
                  bitch.link.present_buddies { |bid, mids|
                    bitch.po.send_to(bitch.link.get_address_of(mids.first[:mbid]),
                        sdata)
                  }
                end
              end
            when STM_DIRECT
              # TODO handle!
            when REQ_PRESENCE
              # TODO handle!
            when REQ_DIRECT
              # TODO handle!
            end #case message_type
          end #message_received()
          
        end
      end
    end
  end
end
