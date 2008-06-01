module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        module ExitHandler
          ModuleRootDir = Pathname(__FILE__).dirname + name.split('::').last
          
          CommandNameRegex = /^\s*exit\s*$/i
          def initialize exit_sync
            @exit_sync = exit_sync
            @command_name_regex = CommandNameRegex
          end
          attr_accessor :command_name_regex
          
          def handles?(comm)
            @command_name_regex.match(comm.name)
          end
          def handle(comm)
            raise unless handles?(comm)
            @exit_sync.value = true
            puts "EXIT IS NOW TRUE"
          end
        end
      end
    end
  end
end
