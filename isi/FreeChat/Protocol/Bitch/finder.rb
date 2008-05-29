module Isi
  module FreeChat
    module Protocol
      module Bitch
        Isi::db_hello __FILE__, name
        
        # Implements the buddy discovery facility of Bitch
        class Finder
          # === Arguments
          # * po : the +PostOffice+
          # * link : the +Linker+
          # * mc : the +MessageCentre+
          # * bbq ; the +BuddyBook+
          # * ui : a +FreeChatUI+
          def initialize po, link, mc, bbq, ui=nil
            @po = po
            @link = link
            @mc = mc
            @bbq = bbq
            @ui = ui
          end
          
          # Initiates search procedure. Should find out all buddies who are
          # present and inform the linker about them. It will also discover
          # buddy mediums for buddies which are present.
          def find_all
            bentries = @bbq.to_enum.map { |bid, entry| entry }
            # First find which buddies are directly connectable?
            ui_finding_all
            bentries.reject! { |entry|
              if raddr = entry.addresses.find { |addr|
                ui_looking_for_buddy entry.id, addr
                @po.reachable? addr
              } then
                @link.buddy_connectable entry.id, raddr
                ui_buddy_connectable entry.id, raddr
                true # reject this entry, it's been used
              end
            }
            ui_fine "Unfound buddies: #{bentries.inspect}"
          end
          
          private ##############################################################
          def ui_looking_for_buddy bid, addr
            ui_fine "Looking for buddy #{bid} at address #{addr}"
          end
          
          def ui_finding_all
            ui_fine "Looking for all buddies..."
          end
          
          def ui_buddy_connectable bid, addr
            ui_fine "Buddy [#{bid}] directly connectable at address #{addr}"
          end
          
          def ui_fine msg
            ui_me Isi::FreeChat::FreeChatUI::FINE, msg
          end
          
          def ui_warn msg
            ui_me Isi::FreeChat::FreeChatUI::WARNING, msg
          end 
          
          def ui_me level, msg
            @ui.bitch_message level, msg
          end
        end
        
        Isi::db_bye __FILE__, name
      end
    end
  end
end
