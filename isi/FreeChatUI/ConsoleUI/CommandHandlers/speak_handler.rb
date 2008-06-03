module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        require ModuleRootDir + 'command_handler'
        class SpeakHandler < CommandHandler
          Isi::db_hello __FILE__, name

          CommandName = 'speak'
          def initialize(silence_setter)
            super(CommandName)
            @silence_setter = silence_setter
          end
          
          def handle(comm)
            @silence_setter[false]
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
