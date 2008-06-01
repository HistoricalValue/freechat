module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        class CommandHandler
          Isi::db_hello __FILE__, name
          
          def initialize regex
            case
            when regex.is_a?(Regexp) then @regex = regex
            when regex.is_a?(String) then @regex = /^\s*#{Regexp::quote(regex)}\s*$/
            else @regex = Regexp::try_convert regex
            end
          end
          attr_accessor :regex
          alias_method :regexp, :regex
          alias_method :regexp=, :regex=
          
          def handles?(comm)
            @regex.match(comm.name)
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
