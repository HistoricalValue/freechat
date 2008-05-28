module Isi
  module FreeChat
    module Protocol
      module Bitch
        Isi::db_hello __FILE__, name
        
        class Bitch
          require 'pathname'
          include Isi::FreeChat, Isi::FreeChat::Protocol::MessageCentre,
              Isi::FreeChat::Protocol::MessageCentre::MessageTypes
          
          DefaultSettingsPath = Pathname(ENV['HOME']) + '.config' + 'freechat'
          
          def initialize my_id,
              ui = Isi::FreeChat::FreeChatUI::new,
              settings_path = DefaultSettingsPath
            @ui = ui
            @id = my_id
            
            # My ID is not allowed to be nil. Ever.
            raise 'my_id.nil? == true' if my_id.nil?
            
            # Mutexes
            
            # A mutex that synchronises all the event methods that Post Office
            # calls
            @po_interface_mutex = Mutex.new
            # Remember...
            loadSettings settings_path
            # A delicate hierarchy of a fragile artifact...
            # Post office
            raise("Myself \"%s\" does not have an entry in BBQ. BBQ: #{
                @bbq}" % @id) if (@my_bbq_entry = @bbq[@id]).nil?
            @po = Isi::FreeChat::PostOffice::PostOffice::new(
                @my_bbq_entry.addresses.first,
                self)
            @ui.b(FreeChatUI::FINER, 'Created post office')
            # Linker
            @link = Isi::FreeChat::Protocol::Linker::Linker::new(@bbq, @ui)
            @ui.b(FreeChatUI::FINER, 'Created linker')
            # Messace centre
            @mc = Isi::FreeChat::Protocol::MessageCentre::MessageCentre::new(
                @po, @link, @ui)
            @ui.b(FreeChatUI::FINER, 'Created message centre')
            
            # @message_handlers is something like this
            # {message_type => [handler, handler, ...] }
            loadMessageHandlers settings_path
            
            # open post office - we are ready to go
            @po.open_up
            # Start message handlers
            @message_handlers.each { |type, mhs| mhs.each { |mh| mh.start } }
          end
          attr_reader :bbq, :po, :mc, :link, :id, :ui

          # Add the given handler to the list of message handlers that the
          # bitch will notify upon arrival of messages.
          #
          # If _msg_types_ +respond_to?+ each, then the given message handler will
          # be registered to receive all message types found in _msg_types_.
          # 
          # If _msg_types_ is not an array then it is presumed that it represents
          # a single message type and then the given message
          # handler will be registered to receive only the specified type in
          # _msg_types_.
          #
          # If _msg_types_ is nil then the message types are acquired by
          # method +#mtypes+ of the given handler.
          #
          # Message types are specified in
          # +Isi::FreeChat::Protocol::MessageCentre::MessageTypes+
          def add_message_handler handler, msg_types=nil
            msg_types = handler.mtypes unless msg_types
            if msg_types.respond_to?(:each) then
              msg_types.each { |mtype|
                add_to = @message_handlers[mtype] = [] unless
                    add_to = @message_handlers[mtype]
                add_to << handler
                @ui.b(FreeChatUI::FINE, "Manually registered handler #{
                    handler.inspect} (for #{mtype})")
              }
            else
              add_to = @message_handlers[msg_types] = [] unless
                  add_to = @message_handlersmtype[msg_types]
              add_to << handler
              @ui.b(FreeChatUI::FINE, "Manually registered handler #{
                  handler.inspect} (for #{msg_types})")
            end
            handler.bitch = self
            handler.start
          end
          
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
              if  msg.type == STM_PRESENT &&
                  msg[RCP] == @id
              then
                @link.remove_untrusted_address addr
                @link.buddy_connectable msg[BID]
                @link.buddy_using_address msg[BID], addr
                @ui.b(FreeChatUI::INFO, "Accepted #{msg[BID]} from address #{
                    addr}")
              else # message from untrusted address is not STM_PRESENT for us...
                # kill
                @po.close_connection addr
                @ui.b(FreeChatUI::WARNING, "Killing untrusted address #{addr
                    }. message: #{@mc.message_to_s msg}")
                @ui.b(FreeChatUI::DEBUG, "[type(#{msg.type} #{@mc.type_to_s msg
                    }) == STM_PRESENT(#{MessageTypes::STM_PRESENT})]=#{
                    msg.type == MessageTypes::STM_PRESENT} && [rcp(#{msg[RCP]
                    }) == id(#{@id})]=#{msg[RCP] == @id} = #{
                    msg.type == MessageTypes::STM_PRESENT &&
                    msg[RCP] == @id}")
              end
            else
              # trusted address - receive message normally.
              
              # forward to appropriate message handlers
              for mh in @message_handlers[msg.type] do
                mh.message_received addr, msg
              end
              @ui.bitch_message(FreeChatUI::FINER, "received: #{
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
                    BID => @id, RCP => @link.get_buddy_using_address(addr)
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
            cont = bbq_path.read
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
                entry[:id] = entry[:id].encode 'utf-8'
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
          
          @@module_name = to_s.sub!(/::\w+$/, '')
          @@System_message_handlers_config = [
            "#{(ModuleRootDir + 'system_message_handler').to_path} #{
                @@module_name}::SystemMessageHandler #{MessageTypes::
                message_types_with_names.map{|name,val|name}.join(' ')}"
          ]
          def loadMessageHandlers config_path
            handlers_config_path = config_path + 'message_handlers.config'
            writeDefaultHandlersConfig handlers_config_path unless
                (handlers_config_path.exist? && handlers_config_path.size > 0)
            @message_handlers = {}
            message_names_to_types = MessageTypes::message_types_with_names
            handler_lines = @@System_message_handlers_config
            handler_lines.concat handlers_config_path.readlines
            handler_lines.each { |handler_line|
              next if handler_line =~ %r{(^#)|(^\s*$)}
              lib, className_and_args, types = handler_line.split(/\s+/, 3)
              require lib
              className, args = className_and_args.split('(')
              if args
                then args = args.sub!('(','').sub!(')','').split(',')
                else args = []
              end
              klass = Isi::getClass className
              if klass.nil? then
                @ui.b(FreeChatUI::WARNING, "Class #{className
                    } not found (for message handler)")
              else
                types.strip!
                types = types.split(%r{\s+})
                handler = klass::new(*args)
                handler.bitch = self
                for type in types do
                  type_val = message_names_to_types[type]
                  if type_val.nil?
                  then @ui.b(FreeChatUI::WARNING, "Unknown message type: #{type
                      }. Ignored.")
                  else
                    @message_handlers[type_val] = [] unless
                        @message_handlers[type_val]
                    @message_handlers[type_val] << handler
                    @ui.b(FreeChatUI::FINE, "Registered handler #{klass} (form #{
                        lib} for #{type}")
                  end
                end
              end
            }
          end
          
          def writeDefaultHandlersConfig path
            path.open(File::CREAT|File::WRONLY) {}
            # no default config
          end

        end
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
