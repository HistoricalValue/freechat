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
                'Greetings to you too, citizen. Do you need [help]?' },
              %r[^\s*(hellow?|hi|heya?|yo)\s+(?<who>\w+)\s*$]i => proc { |md, _|
                "Greetings. My name is not #{md[:who]}. Do you need [help]?" },
              %r[^\s*(i\s*(do)?\s*(need|want|would like)\s*)?help\s*$]i => proc {
                ['You have the following choices: find out who is [present] or',
                 '[contact] someone who is present. You can ask for more help',
                 'about those two.']},
              %r[^\s*help\s*present\s*$]i => proc {
                'If you ask about [present] buddies I shall tell who is amidst the living.'},
              %r[^\s*help\s*contact\s*$]i => proc {
                ['If you want to [contact] someone, they have to be present, I cannot speak to the dead (yet).',
                 'You also would have to tell me [who] do you want to contact.']},
              %r[^\s*present\s*$]i => proc {
                # find out who is present
                present = b.link.present_buddies.to_a.map!{ |id, _| id }
                if present.empty? then
                  result = ['Nobody is present for you tonight...']
                else
                  result = ["It seems that #{if present.length > 1
                      then "#{present[0..-2].join ', '} and #{present.last} are"
                      else "#{present.first} is" end} with us tonight."]
                end
                if b.finder.discovering? then
                  result << 'Keep in mind that the spirits are still restless.'
                  result << 'You might find that more are present in a while.'
                end
                result # return
              },
              %r[^$] => proc { 'What do you want? [Help]?' },
              %r[] => proc { |_, msg| 
                "I do not understand \"#{msg}\". Do you need [help]?" },
            }
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
