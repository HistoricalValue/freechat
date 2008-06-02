module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        require ModuleRootDir + 'command_hanlder'
        
        class SilenceHandler < CommandHandler
          Isi::db_hello __FILE__, name
          
          CommandName = 'silence'
          def initialize silence_setter
            super(CommandName)
            @silence_setter = silence_setter
          end

          def handle(comm)
            # pass a true, for extra info
            args = []
            if @silence_setter.respond_to?(:lambda?)
              if @silence_setter.lambda?
                if @silence_setter.respond_to?(:arity)
                  if @silence_setter.arity != 0
                    args[0] = true
                  end
                end
              else
                args[0] = true
              end
            end
            @silence_setter.call(*args)
          end
          
          Isi::db_bye __FILE__, name
        end
        
      end
    end
  end
end
