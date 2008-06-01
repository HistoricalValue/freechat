module Isi
  module FreeChat
    module Protocol
      module Bitch
        Isi::db_hello __FILE__, name
        
        # Implements the buddy discovery facility of Bitch
        class Finder
          # The arguments are named arguments passed as a hash. The names
          # listed below are supposed to be used as symbol keys in the Hash.
          # In the parentheses next to the argument name is the default value
          # which will be assigned to it if it is missing or +nil+. If N/A is
          # listed in the parentheses it means that there is no default value
          # for this parameter and it will result in an +ArgumentError+
          # being raised.
          # === Parameters
          # * po    (N/A) : the +PostOffice+
          # * link  (N/A) : the +Linker+
          # * mc    (N/A) : the +MessageCentre+
          # * bbq   (N/A) ; the +BuddyBook+
          # * my_id (N/A) : my ID (to avoid searching for it)
          # * ui    (nil) : a +FreeChatUI+
          def initialize nargs
            @po   = nargs[:po   ] or raise ArgumentError::new('po'   )
            @link = nargs[:link ] or raise ArgumentError::new('link' )
            @mc   = nargs[:mc   ] or raise ArgumentError::new('mc'   )
            @bbq  = nargs[:bbq  ] or raise ArgumentError::new('bbq'  )
            @id   = nargs[:my_id] or raise ArgumentError::new('my_id')
            @ui   = nargs[:ui   ]
            
            @discovering = Isi::SynchronizedValue::new false
          end
          
          # Initiates search procedure. Should find out all buddies who are
          # present and inform the linker about them. It will also discover
          # buddy mediums for buddies which are present.
          def find_all
            @discovering.value = true
            Thread::new {
              bentries = @bbq.to_enum.map { |bid, entry| entry }
              # First find which buddies are directly connectable?
              ui_finding_all
              bentries.reject! { |entry|
                case
                when entry.id == @id # this is me, i am not looking for me, i'm here
                  true
                when raddr = entry.addresses.find { |addr|
                  ui_looking_for_buddy entry.id, addr
                  if @po.reachable? addr then true # ok
                  else ui_buddy_not_connectable entry.id, addr; false end
                } then
                  @link.buddy_connectable entry.id, raddr
                  ui_buddy_connectable entry.id, raddr
                  true # reject this entry, it's been used
                else
                  false # keep the entry for further search
                end
              }
              ui_fine "Unfound buddies: #{bentries.inspect}"
              @discovering.value = false
            }
          end
          
          def discovering?
            @discovering.value
          end
          alias_method :finding?, :discovering?
          
          private ##############################################################
          def ui_looking_for_buddy bid, addr
            ui_fine "Looking for buddy #{bid} at address #{addr}"
          end
          
          def ui_buddy_not_connectable bid, addr
            ui_fine "Buddy #{bid} at #{addr} is not connectable"
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
