# encoding: UTF-8
$isi = {
  :debug_hello => !true,
  :debug_bye =>   !true,
}
$ENV = ENV
$:.unshift('trunk')
require 'isi/freechat'
require 'isi/freechatui'
include Isi, Isi::FreeChat, Isi::FreeChat::Protocol::MessageCentre::MessageTypes,
    Isi::FreeChat::Protocol::Bitch, Isi::FreeChatUI

$UI_LEVEL = Isi::FreeChat::FreeChatUI::FINER
$ONLY_FROM = /JUI-comm/
$UI_DISREGARDS = !true
class ShutupyUI < Isi::FreeChat::FreeChatUI
  def initialize args
    @id = args[:id]; raise unless @id
    @main_on = args[:main] || true
    @main_level = args[:main_level] || $UI_LEVEL
    @only_from = args[:only_from] || $ONLY_FROM
    @disregards = args[:disregards] || $UI_DISREGARDS
  end
  attr_accessor :main_on, :only_from
  def main_on?
    main_on
  end
  def default_print_message_from(from, level, msg)
    if (!@only_from || from =~ @only_from)
      if level <= $UI_LEVEL
        super(from, level, "(#{@id})__--``--__ #{msg}")
      else
        puts "Disregarding message level #{level}" if @disregards
      end
    else
      puts "Disregarding message from #{from}" if @disregards
    end
  end
  def main(level,msg)
    default_print_message_from('main', level, msg) if main_on?
  end
  def m(msg)
    main(@main_level, msg)
  end
end

begin
  

Self1, Port1, Self2, Port2, Case = ARGV[0..4]
Eva = 'Ευανθια'

# Make my UI
Main_id = 'Juumala'
Main_ui = ShutupyUI::new(:id => Main_id)

Yksi_id = Self1.encode 'utf-8'
Kaksi_id = Self2.encode 'utf-8'

if Case == '1' then
  Main_id << '_' << Yksi_id
  # Start 1
  Main_ui.m "Starting #{Self1} to port #{Port1}"
  Yksi_ui = ShutupyUI::new(:id => Yksi_id)
  Yksi_b  = Bitch::new Yksi_id, Yksi_ui
  Yksi_jui_mh = JUICommunicator::new(Port1)
  Yksi_b.add_message_handler Yksi_jui_mh
  Yksi_b.link.buddy_connectable Kaksi_id
end

if Case == '2' then
  Main_id << '_' << Kaksi_id
  # Start 2
  Main_ui.m "Starting #{Self2} to port #{Port2}"
  Kaksi_ui = ShutupyUI::new(:id => Kaksi_id)
  Kaksi_b = Bitch::new Kaksi_id, Kaksi_ui
  Kaksi_jui_mh = JUICommunicator::new(Port2)
  Kaksi_b.add_message_handler Kaksi_jui_mh
  Kaksi_b.link.buddy_connectable Yksi_id
  # Manual send to Yksi
  Kaksi_b.mc.send_message(Kaksi_b.mc.create_message(STM_MESSAGE, RCP => Yksi_id,
      FRM => Kaksi_id, CNT => 'Hello bobakla'))
end

Main_ui.m 'Send kill signal to end'
loop { sleep 1 }
puts "THE END"

rescue Exception => e
  puts e
  puts e.backtrace.map {|s| "    #{s}" }.join("\n")
end