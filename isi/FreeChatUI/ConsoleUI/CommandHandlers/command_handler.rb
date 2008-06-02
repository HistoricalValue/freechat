module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        class CommandHandler
          Isi::db_hello __FILE__, name
          
          def initialize command_name
            raise ArgumentError::new("command_name(#{command_name.inspect
               }) is not a #{String}") unless command_name.is_a?(String)
            @command_name = command_name
          end
          attr_accessor :command_name
          
          def handles?(comm)
            @command_name == comm
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
