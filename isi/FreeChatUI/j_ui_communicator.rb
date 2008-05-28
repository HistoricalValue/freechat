module Isi
  module FreeChatUI
    require ModuleRootDir + '../freechat'
    class JUICommunicator < Isi::FreeChat::Protocol::Bitch::MessageHandler
      require 'rexml/document'
      require 'socket'
      include Socket::Constants,
          Isi::FreeChat::Protocol::MessageCentre::MessageTypes
      
      ServingSleepnessSeconds = 1
      
      def initialize port
        @mtypes = [STM_MESSAGE]; @mtypes.freeze
        @socket = Socket::new AF_INET, SOCK_STREAM, 0
        @jui_sockaddr = Socket::pack_sockaddr_in port, 'localhost'
        @msg_i = Struct::new(:type, :args)::new(-1, {})
        def @msg_i.clear; self.type = -1; self.args.clear; self end
        
        @servin_lambda = lambda {
          until @socket.eof? do
            buf = ''
            while (c = @socket.readchar) != "\n" do
              buf << c
            end
            # now buffy contains an xml-y
            # parse it!
            begin
            doc = REXML::Document::new buf
            # find message element
            for element in doc.elements do
              if element.name == 'message'
                message_el = element
                break
              end
            end
            ui_fine 'Parsing new message'
            # Clear message info struct
            @msg_i.clear
            message_el.elements.each { |el| 
              case el.name
              when 'argument' then
                ui_fine 'Parsing an argument'
                el.attributes.each { |attr, val| 
                  case attr
                  when 'name' then
                    @msg_i.args[val] = el.text
                    ui_fine "(#{attr}=#{val}) msg[#{val}] = #{el.text}"
                  else
                    ui_warn "Ignoring unknows attribute of argument: #{attr}=#{val}"
                  end
                }
              when 'type' then
                @msg_i.type = message_types_with_names[el.text]
                raise "Not a valid message type: #{el.text}" unless @msg_i.type
                ui_fine "msg.type = #{el.text}"
              else
                ui_warn "Ignoring element of unknown name: #{el.name}"
              end
            }
            ui_fine "Ready to make message with: #{@msg_i}"
            msg = bitch.mc.create_message(@msg_i.type, @msg_i.args)
            ui_fine "Made message: #{msg}"
            # send it
            bitch.mc.send_message msg
            rescue Exception => e
              ui_warn "#{e}\n#{e.backtrace.join("\n")}"
            end
          end
        }
      end
      attr_reader :mtypes
      
      def port
        Socket::unpack_sockaddr_in(@jui_sockaddr).at(0)
      end
      
      def ip
        Socket::unpack_sockaddr_in(@jui_sockaddr).at(1)
      end
      
      def connect_and_serve
        @socket.connect @jui_sockaddr
        # We need two threads, one to receive messages and one to send out
        # the ones we receive as UI.

        Thread::new(&@servin_lambda)
      end
      alias_method :start, :connect_and_serve
      
      include Isi::FreeChat::Protocol::MessageCentre::MessageTypes
      def message_received addr, msg
        unless msg.type != STM_MESSAGE then
          # send to jui
          @socket.write \
              '<?xml version="1.0" encoding="UTF-8"?><message><type>STM_MESSAGE</type>'
          msg.each_argument { |arg_pair|
            @socket.write('<argument name="%s">%s</argument>' % arg_pair)
          }
          @socket.puts "</message>"
          @socket.flush
        else
          bitch.ui.generic_message('JUI-comm',
              Isi::FreeChat::FreeChatUI::WARNING,
              'passing message of type other than STM_MESSAGE to ' +
              self.class.name + '. STM_MESSAGE(' + STM_MESSAGE.to_s +
              ') == ' + message_types_with_names.rassoc(msg.type).first.to_s +
              '(' + msg.type.to_s + ') -> ' + (STM_MESSAGE == msg.type).to_s)
        end
      end
      
      private ##################################################################
      def ui_warn msg
        ui_me Isi::FreeChat::FreeChatUI::WARNING, msg
      end
      
      def ui_info msg
        ui_me Isi::FreeChat::FreeChatUI::INFO, msg
      end
      
      def ui_fine msg
        ui_me Isi::FreeChat::FreeChatUI::FINE, msg
      end
      
      def ui_me level, msg
        bitch.ui.generic_message('JUI-comm', level, msg)
      end
      
    end
  end
end
