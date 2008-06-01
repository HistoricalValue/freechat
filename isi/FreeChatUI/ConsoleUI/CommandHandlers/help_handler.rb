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
            ].join((ENV['LINESEPARATOR'] or ENV['LINE_SEPARATOR'] or "\n")),
              { 'list' => HelpModule::new('list',
                  'lists all open windows and their status',
                  ['Lists all open windows.',
                   '',
                   'The first field is the window ID. This can be used as an',
                   'argument for the /window command in order to select a ',
                   'window. The second field is the window title. The third ',
                   'field is the window status: - means the window is inactive',
                   '(nothing new), * means there is something new (unviewed)'
                  ].join((ENV['LINESEPARATOR'] or ENV['LINE_SEPARATOR'] or "\n")), {}),
                'silence' => HelpModule::new('silence', 'stops outputing anything', 'silence help', {}),
                'speak' => HelpModule::new('speak', 'resumes outputing', 'speak help', {}),
                'window' => HelpModule::new('window', 'select a window to show (argument is the IDs from list)', 'window help', {}),
                'close' => HelpModule::new('close', 'closes the currently active window', 'close help', {}),
                'exit' => HelpModule::new('exit', 'exits from the program', 'exit help', {})
              })
          
          CommandRegex = /^\s*h(elp)?\s*$/
          def initialize 
            super(CommandRegex)
            
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
            puts result
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
