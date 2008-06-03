module Isi
  module FreeChatUI
    module ConsoleUI
      module SystemInterpreters
        module SystemInterpreter
          Isi::db_hello __FILE__, name
          
          def new_message(message)
            raise RuntimeError::new('Unimplemented method "new_message" for ' +
                "system interpreter #{self.class.inspect} (message: #{
                message.inspect}")
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
