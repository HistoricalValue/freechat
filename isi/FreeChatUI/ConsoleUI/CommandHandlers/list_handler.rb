module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        require ModuleRootDir + 'command_handler'
        class ListHandler < CommandHandler
          Isi::db_hello __FILE__, name
          
          WindowsInfo = Struct::new(:id, :title, :status, :active)
          
          CommandName = 'list'
          def initialize windows, active_window_reader
            super(CommandName)
            @windows = windows
            @active_window_reader = active_window_reader
          end
          
          def handle comm
            windows_infos = @windows.sort { |a, b| a.id <=> b.id }.map!{ |win|
              WindowsInfo::new(*
                  [   win.id, 
                      win.title,
                      if win.unread? then '*' else '-' end,
                      if win.id == @active_window_reader.call then ' <-' end
                  ].map(&:to_s))
            }
            max_id_len = windows_infos.max { |a, b|
              a.id.length <=> b.id.length
            }.id.length
            max_title_len = windows_infos.max { |a, b|
              a.title.length <=> b.title.length
            }.title.length
            max_status_len = 1
            windows_infos.each { |i|
              active_mark = (if i.id == @active_window_reader.call
                             then ' <-' end)
              puts('%*s : %*s %*s%s' % [
                  max_id_len, i.id,
                  max_title_len, i.title,
                  max_status_len, i.status,
                  i.active,
              ])
            }
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
