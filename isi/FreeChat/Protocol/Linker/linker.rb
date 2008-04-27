module Isi
  module FreeChat
    module Protocol
      module Linker
        # Linker is the class responsible for knowing how each Buddy can
        # be actually reached (through which other buddy, etc). It is also
        # responsible for discovering those paths and who is currently
        # available.
        # 
        # === Arguments
        # * bbq : a BuddyBook
        class Linker
          def initialize bbq
            @bbq = bbq
          end
          
          # Starts discovery of available buddies and buddy paths.
          # To speed up the discovery process, each buddy is attempted
          # to be reached directly and if this fails, buddypath discovery
          # is enabled.
          def discovery
            @bbq.each { |bid, bentry| 
              
            }
          end
        end
      end
    end
  end
end
