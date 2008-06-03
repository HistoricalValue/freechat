module Isi
  module FreeChatUI
    module ConsoleUI
      module SystemInterpreters
        require ModuleRootDir + 'system_interpreter'
        
        class BitchInterpreter
          Isi::db_hello __FILE__, name
          
          include SystemInterpreter
          
          def initialize bitch
            @bitch = bitch
            # @responses -> { regex => response }
            install_responses
          end
          attr_reader :bitch
          alias_method :b, :bitch
          
          def new_message(message)
            match_data = nil
            @responses.find { |rx, _|
              match_data = rx.match(message)
            }.at(1).call(match_data, message)
          end
          
          private ##############################################################
          def install_responses
            @responses = {
              %r[^\s*(hellow?|hi|heya?|yo)(\s+b(ia?(tcha?)?)?)?\s*$]i => proc {
                'Greetings to you too, citizen.' },
              %r[^\s*(hellow?|hi|heya?|yo)\s+(?<who>\w+)\s*$]i => proc { |md, _|
                "Greetings. My name is not #{md[:who]}." },
              %r[^$] => proc { 'What do you want?' },
              %r[] => proc { |_, msg| 
                "I do not understand \"#{msg}\"" },
            }
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
