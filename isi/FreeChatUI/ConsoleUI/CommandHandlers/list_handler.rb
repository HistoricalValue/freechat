module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        require ModuleRootDir + 'command_handler'
        class ListHandler < CommandHandler
          Isi::db_hello __FILE__, name
          
          WindowsInfo = Struct::new(:id, :title, :status, :active)
          
          CommandName = 'list'
          def initialize windows_giver, active_window_giver
            super(CommandName)
            @windows_giver = windows_giver
            @active_window_giver = active_window_giver
          end
          
          def handle comm
            windows_sorted = @windows_giver.call { |windows|
              windows.values.sort { |a, b| a.id <=> b.id }
            }
            windows_infos = @active_window_giver.call { |active_window|
              windows_sorted.map!{ |win|
                WindowsInfo::new(*
                    [   win.id, 
                        win.title,
                        if win.unread? then '*' else '-' end,
                        if win.id == active_window then ' <-' end
                    ].map(&:to_s))
              }
            }
            max_id_len = windows_infos.max { |a, b|
              a.id.length <=> b.id.length
            }.id.length
            max_title_len = windows_infos.max { |a, b|
              a.title.length <=> b.title.length
            }.title.length
            max_status_len = 1
            windows_infos.each { |i|
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
