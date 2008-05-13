module Isi
  module FreeChat
    module Protocol
      module Bitch
        class Bitch
          require 'pathname'
          
          DefaultSettingsPath = Pathname($ENV['HOME']) + '.config' + 'freechat'
          def initialize my_id,
              ui = Isi::FreeChat::FreeChatUI::new,
              settings_path = DefaultSettingsPath
            @ui = ui
            # Remember...
            loadSettings settings_path
            # A delicate hierarchy of a fragile artifact...
            # Post office
            @po = Isi::FreeChat::PostOffice::PostOffice::new(
                @bbq[my_id].addresses.first,
                self)
            @ui.b(FreeChatUI::FINER, 'Created post office')
            # Linker
            @link = Isi::FreeChat::Protocol::Linker::Linker::new(@bbq, @ui)
            @ui.b(FreeChatUI::FINER, 'Created linker')
            # Messace centre
            @mc = Isi::FreeChat::Protocol::MessageCentre::MessageCentre::new(
                @po, @link, @ui)
            @ui.b(FreeChatUI::FINER, 'Created message centre')
          end
          attr_reader :bbq
          
          def bye
            @po.close_down
          end
          
          private
          def loadSettings settings_path
            settings_path.mkpath
            bbq_path = settings_path + 'bbq.str'
            @ui.b(FreeChatUI::FINER, "Loading BBQ data from #{bbq_path}")
            loadBBQ(bbq_path)
            @ui.b(FreeChatUI::FINER, 'BBQ loaded successfully')
          end
          
          def loadBBQ bbq_path
            writeDefaultBBQConfig bbq_path unless (bbq_path.exist? && 
                  bbq_path.size > 0)
            @bbq = Isi::FreeChat::BuddyBook::BuddyBook::new
            cont = nil
            bbq_path.open(File::RDONLY) { |fin| cont = fin.read }
            cont = cont.encode 'ascii'
            cont = cont.chars
            # FSM!
            state = 'init'
            entry = {}
            while state != 'end'
            case state
            when 'init'
              case char = cont.next
              when "\x00" then state = 'end'
              else # read until \x00
                entry[:id] = char
                while (c = cont.next) != "\x00" do entry[:id] << c end
                @ui.b(FreeChatUI::FINEST, "Reading address infor for #{entry[:id]}")
                state = 'buddy_id_read'
              end
            when 'buddy_id_read'
              # read number of addresses
              entry[:addr_num] = cont.next
              while (c = cont.next) != "\x00" do entry[:addr_num] << c end
              entry[:addr_num] = entry[:addr_num].to_i
              @ui.b(FreeChatUI::FINEST, "#{entry[:addr_num]} addresses to be read for #{entry[:id]}")
              state = 'addr_num_read'
            when 'addr_num_read'
              entry[:addresses] = []
              # read addr_num addresses
              entry[:addr_num].times {
                ip = cont.next
                while (c = cont.next) != "\x00" do ip << c end
                port = cont.next
                while (c = cont.next) != "\x00" do port << c end
                entry[:addresses] << Isi::FreeChat::PostOffice::Address.
                    new(ip, port)
                @ui.b(FreeChatUI::FINEST, "Added #{entry[:addresses].last}")
              }
              state = 'entry_read'
            when 'entry_read'
              # save entry to buddy book
              @bbq << Isi::FreeChat::BuddyBook::BuddyEntry::new(entry[:id],
                entry[:addresses])
              @ui.b(FreeChatUI::FINEST,"Done with entry for #{entry[:id]}")
              state = 'init'
            else
              raise 'Invalid state'
            end
            end # while case =/= end
            @ui.b(FreeChatUI::FINEST, 'Done parsing bbq data')
          end
          
          def writeDefaultBBQConfig bbq_path
            File.open(bbq_path.to_path, File::CREAT|File::WRONLY|File::TRUNC,
                0600) { |fout|
              fout.write "\x00"
            }
          end
          
        end
      end
    end
  end
end
