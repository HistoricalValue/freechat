module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        require ModuleRootDir + 'command_handler'
        
        class HelpHandler < CommandHandler
          Isi::db_hello __FILE__, name
          
          require 'abbrev'
          
          class HelpModule
            def initialize title, short_text, text, kids
              @title = title
              @text = text
              @kids = kids
              @short_text = short_text
            end
            attr_reader :title, :short_text, :kids
            def to_s
              text
            end
            
            def text
              result = "#{@text}\n"
              if @kids.length > 0 
                kids = @kids.map { |k, hm| [k.to_s, hm.short_text]}
                max_len = kids.max { |a,b| a.first.length <=> b.first.length }.
                    first.length
                for pair in kids do result<<("\n%-#{max_len}s %s"%pair) end
              end
              result
            end
          end
          
          GenericHelp = HelpModule::new(
              'General', 'displays general help info',
            ['To find out more about a specific command type /help <command>.',
             'Every command name can be abbreviated to an unambiguous minimum.',
            ].join(Isi::ENDL),{
                'general' => HelpModule::new('general',
                  'explains the general idea of this user interface',
                  ['The general idea',
                   '',
                   'This is a console user interface which does not use any',
                   'fancy cursor libraries in order to emulate a window',
                   'environment on the console. Instead it is based on the',
                   'idea that the user can pause all output when she wants',
                   'to enter input. This happens with the pair of actions: ',
                   '/speak and interrupt signals (ctrl+C from console).',
                   'When the interface is in silence mode no messages are',
                   'written expect for a prompt. In silence mode the user can',
                   'enter commands or write messages to the active window.',
                   'Go break the silence, the user needs to issue the /speak',
                   'command. When not in silence mode (in noise mode), the',
                   'interface will print new messages that arrive for the',
                   'active window or various system messages. User input is',
                   'disregarded when in noise mode. To leave the noise mode',
                   'and go back to silence, one needs to send an interrupt',
                   'signal while in noise mode (ctrl + C from a console).',
                   'The interface begins in silence mode.',
                   '',
                   'The user can also cancel the next line that would be',
                   'read by sending a interrupt signal to the interface',
                   '(ctrl + C from a terminal) while in silence mode.'
                  ].join(Isi::ENDL), {}),
                'list' => HelpModule::new('list',
                  'lists all open windows and their status',
                  ['Lists all open windows.',
                   '',
                   'The first field is the window ID. This can be used as an',
                   'argument for the /window command in order to select a ',
                   'window. The second field is the window title. The third ',
                   'field is the window status: - means the window is inactive',
                   '(nothing new), * means there is something new (unviewed)',
                  ].join(Isi::ENDL), {}),
                'speak' => HelpModule::new('speak', 'resumes outputing',
                  ['Allows output to be written again',
                    '',
                    'If this user interface has be silenced, then /speak will',
                    'put the interface back in noise mode.',
                    '',
                    'For more information, read /help general.',
                  ].join(Isi::ENDL), {}),
                'window' => HelpModule::new('window',
                  'select a window to show (argument is the IDs from list)',
                  ['Selects which should be the active window',
                   '',
                   'Selects which window should be the current/active one.',
                   'The argument for this command is the ID column from the',
                   '/list command.',
                   'When a window is active then its unread (new) content will',
                   'be written to the output (when in noise mode) and any',
                   'messages written by the user will be send to the buddy the',
                   'active window corresponds to (in silence mode).',
                   'If the active window is a system window (title: bitch)',
                   'then messages are send to the bitch. This can be used to',
                   'see or set configuration and more. Try the bitch for',
                   '"help".',
                  ].join(Isi::ENDL), {}),
                'close' => HelpModule::new('close',
                  'closes the currently active window',
                  ['Closes the active window',
                   '',
                   'Closing the active window means that it will be disposed,',
                   'all conversation buffers will be erased. It will also stop',
                   'appearing by the /list command.',
                   '',
                   'A window with the same title might be re-created later if',
                   'an appropriate message is to be displayed under that ',
                   'title.',
                  ].join(Isi::ENDL), {}),
                'exit' => HelpModule::new('exit', 'exits from the program',
                  ['Exits from the program',
                    '',
                    'This command will cause the program to exit. Any ongoing',
                    'operation (such as buddy discovery in the background)',
                    'will be stopped. This is the clean way to exit the ',
                    'programm.',
                  ].join(Isi::ENDL), {})
              })
          
          UnknownTopic = 'Unknown topic'
          CommandName = 'help'
          def initialize 
            super(CommandName)
            
            # Abbrevs is something like 
            #     {HelpModule => abbrev hash}
            @abbrevs = {}
          end
          
          def handle(comm)
            emptiness = /^\s*$/
            args = comm.args.reject { |a| a =~ emptiness }
            result = GenericHelp
            for arg in args do
              ensure_abbrevs_for result
              result = result.kids[@abbrevs[result][arg]]
            end
            if result then puts result else puts "#{UnknownTopic}: #{
              comm.name}(#{comm.args.join(', ')})" end
          end
          
          private ##############################################################
          def ensure_abbrevs_for help_mod
            unless @abbrevs[help_mod]
              @abbrevs[help_mod] = help_mod.kids.keys.abbrev
            end
          end
          
          Isi::db_bye __FILE__, name  
        end
      end
    end
  end
end
