module Isi
  module FreeChat
    module Protocol
      module Bitch
        class Bitch
          require 'pathname'
          include Isi::FreeChat, Isi::FreeChat::Protocol::MessageCentre
          
          DefaultSettingsPath = Pathname(ENV['HOME']) + '.config' + 'freechat'
          def initialize my_id,
              ui = Isi::FreeChat::FreeChatUI::new,
              settings_path = DefaultSettingsPath
            @ui = ui
            @id = my_id
            # Mutexes
            
            # A mutex that synchronises all the event methods that Post Office
            # calls
            @po_interface_mutex = Mutex.new
            # Remember...
            loadSettings settings_path
            # A delicate hierarchy of a fragile artifact...
            # Post office
            @po = Isi::FreeChat::PostOffice::PostOffice::new(
                @bbq[my_id].addresses.first,
                self)
            @ui.b(FreeChatUI::FINER, 'Created post office')
            # Linker
            @link = Isi::FreeChat::Protocol::Linker::Linker::new(@bbq, @ui)
            @ui.b(FreeChatUI::FINER, 'Created linker')
            # Messace centre
            @mc = Isi::FreeChat::Protocol::MessageCentre::MessageCentre::new(
                @po, @link, @ui)
            @ui.b(FreeChatUI::FINER, 'Created message centre')
          end
          attr_reader :bbq, :po, :mc, :link, :id
          
          def bye
            @po.close_down
          end
          
          # Interface for post office --everything synchronised
          
          # Received a packet from post office. Deal with it.
          def packet_received addr, data
            @po_interface_mutex.synchronize {
              packet_received_synchronised addr, data
            }
          end
          def packet_received_synchronised addr, data
            msg = @mc.deserialise data
            if @link.address_untrusted?(addr) then
              # this better be an identification message
              if  msg.type == MessageTypes::STM_PRESENT &&
                  msg['rcp'] == @id
              then
                @link.remove_untrusted_address addr
                @link.buddy_using_address msg['bid'], addr
                @ui.b(FreeChatUI::INFO, "Accepted #{msg['bid']} from address #{
                    addr}")
              else # message from untrusted address is not STM_PRESENT for us...
                # kill
                @po.close_connection addr
                @ui.b(FreeChatUI::WARNING, "Killing untrusted address #{addr
                    }. message: #{@mc.message_to_s msg}")
                @ui.b(FreeChatUI::DEBUG, "[type(#{msg.type} #{@mc.type_to_s msg
                    }) == STM_PRESENT(#{MessageTypes::STM_PRESENT})]=#{
                    msg.type == MessageTypes::STM_PRESENT} && [rcp(#{msg['rcp']
                    }) == id(#{@id})]=#{msg['rcp'] == @id} = #{
                    msg.type == MessageTypes::STM_PRESENT &&
                    msg['rcp'] == @id}")
              end
            else
              # trusted address
              @ui.bitch_message(FreeChatUI::INFO, "received: #{
                  @link.get_buddy_using_address addr} -> #{
                  @mc.message_to_s(msg)}")
            end
          end
          # A new connection is untrusted until a message of type
          # +STM_PRESENT+ comes from it with 'rcp' being us and 'bid' being
          # some buddy. Then the connection becomes trusted and is marked as
          # being used from buddy found in argument 'bid' of the message.
          # If anything else other than such a type of message is received
          # from that address before this message, post office is istructed
          # to close the connection.
          def connection_received addr
            @po_interface_mutex.synchronize {
              connection_received_synchronised addr
            }
          end
          def connection_received_synchronised addr
            @link.register_untrusted_address addr
          end
          # Notification from the post office that a new connection has been
          # made to the given address. Assuming that we only connect to other
          # buddies running the same software as we are (...), we have to send
          # an identification message as described in +connection_received_+.
          def created_connection addr
            @po_interface_mutex.synchronize {
              created_connection_synchronised addr
            }
          end
          def created_connection_synchronised addr
            # send identification message
            @po.send_to(addr,
                @mc.create_message(MessageTypes::STM_PRESENT,
                    'bid' => @id, 'rcp' => @link.get_buddy_using_address(addr)
                    ).serialise
                )
          end
          private ##############################################################
          def loadSettings settings_path
            settings_path.mkpath
            bbq_path = settings_path + 'bbq.str'
            @ui.b(FreeChatUI::FINER, "Loading BBQ data from #{bbq_path}")
            loadBBQ(bbq_path)
            @ui.b(FreeChatUI::FINER, 'BBQ loaded successfully')
          end
          
          def loadBBQ bbq_path
            writeDefaultBBQConfig bbq_path unless (bbq_path.exist? && 
                  bbq_path.size > 0)
            @bbq = Isi::FreeChat::BuddyBook::BuddyBook::new
            cont = nil
            bbq_path.open(File::RDONLY) { |fin| cont = fin.read }
            cont = cont.encode 'ascii'
            cont = cont.chars
            # FSM!
            state = 'init'
            entry = {}
            while state != 'end'
            case state
            when 'init'
              case char = cont.next
              when "\x00" then state = 'end'
              else # read until \x00
                entry[:id] = char
                while (c = cont.next) != "\x00" do entry[:id] << c end
                @ui.b(FreeChatUI::FINEST, "Reading address infor for #{entry[:id]}")
                state = 'buddy_id_read'
              end
            when 'buddy_id_read'
              # read number of addresses
              entry[:addr_num] = cont.next
              while (c = cont.next) != "\x00" do entry[:addr_num] << c end
              entry[:addr_num] = entry[:addr_num].to_i
              @ui.b(FreeChatUI::FINEST, "#{entry[:addr_num]} addresses to be read for #{entry[:id]}")
              state = 'addr_num_read'
            when 'addr_num_read'
              entry[:addresses] = []
              # read addr_num addresses
              entry[:addr_num].times {
                ip = cont.next
                while (c = cont.next) != "\x00" do ip << c end
                port = cont.next
                while (c = cont.next) != "\x00" do port << c end
                entry[:addresses] << Isi::FreeChat::PostOffice::Address.
                    new(ip, port)
                @ui.b(FreeChatUI::FINEST, "Added #{entry[:addresses].last}")
              }
              state = 'entry_read'
            when 'entry_read'
              # save entry to buddy book
              @bbq << Isi::FreeChat::BuddyBook::BuddyEntry::new(entry[:id],
                entry[:addresses])
              @ui.b(FreeChatUI::FINEST,"Done with entry for #{entry[:id]}")
              state = 'init'
            else
              raise 'Invalid state'
            end
            end # while case =/= end
            @ui.b(FreeChatUI::FINEST, 'Done parsing bbq data')
          end
          
          def writeDefaultBBQConfig bbq_path
            File.open(bbq_path.to_path, File::CREAT|File::WRONLY|File::TRUNC,
                0600) { |fout|
              fout.write "\x00"
            }
          end
          
        end
      end
    end
  end
end
