module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        require ModuleRootDir + 'command_handler'
        
        class CloseHandler < CommandHandler
          Isi::db_hello __FILE__, name
          
          CommandName = 'close'
          def initialize windows_giver, active_window_giver, is_system
            super(CommandName)
            @windows_giver = windows_giver
            @active_window_giver = active_window_giver
            @is_system = is_system
          end
          
          def handle(comm)
            active_window = @active_window_giver.call { |aw| aw }
            if @is_system[active_window] then
              puts "Not allowed to close system window (#{active_window})"
            else
              deleted = @windows_giver.call { |windows|
                windows.delete(active_window)
              }
              if deleted.nil? then 
                puts "Window does not exist: #{active_window}"
              end
            end
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
