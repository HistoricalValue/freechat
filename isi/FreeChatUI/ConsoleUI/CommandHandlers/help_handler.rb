module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        require ModuleRootDir + 'command_handler'
        
        class HelpHandler < CommandHandler
          Isi::db_hello __FILE__, name
          
          GenericHelp = 0
          HelpText = [
            ['To find out more about a specific command type /help <command>.',
             'Every command name can be abbreviated to an unambiguous minimum.',
             '',
             'list     lists all open windows and their status',
             'silence  stops outputing anything',
             'speak    resumes outputing',
             'window   select a window to show (argument is the IDs from list)',
             'close    closes the currently active window',
            ].join((ENV['LINESEPARATOR'] or ENV['LINE_SEPARATOR'] or "\n"))
          ]
          
          CommandRegex = /^\s*h(elp)?\s*$/
          def initialize 
            super(CommandRegex)
          end
          
          def handle(comm)
            if comm.args.length == 0
              puts HelpText[GenericHelp]
            end
          end
          
          Isi::db_bye __FILE__, name  
        end
      end
    end
  end
end
