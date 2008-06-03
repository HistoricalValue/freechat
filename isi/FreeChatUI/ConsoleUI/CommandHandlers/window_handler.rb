module Isi
  module FreeChatUI
    module ConsoleUI
      module CommandHandlers
        require ModuleRootDir + 'command_handler_exception'
        
        class WindowHandler < CommandHandler
          Isi::db_hello __FILE__, name
          
          CommandName = 'window'
          def initialize windows_giver, setter
            super(CommandName)
            @windows_giver = windows_giver
            @setter = setter
          end
          
          def handle(comm)
            winid = extract_arguments(comm.args)
            @setter.call(winid)
          rescue CommandHandlerException => e
            puts "/#{comm.name}: error: #{e.message}"
          end
          
          private ##############################################################
          #     extract_arguments(args) -> winid
          def extract_arguments(args)
            winid = args.at(0)
            raise CommandHandlerException::new("No window ID given") unless winid
            winid_i = winid.to_i
            raise CommandHandlerException::new("Invalid ID: #{winid}") unless 
                 @windows_giver.call { |ww| ww.any? { |id, _| id == winid_i } }
            winid = winid_i
            # return
            winid
          end
          
          Isi::db_bye __FILE__, name
        end
      end
    end
  end
end
