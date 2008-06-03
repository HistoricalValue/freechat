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

$UI_LEVEL = Isi::FreeChat::FreeChatUI::WARNING
$ONLY_FROM = nil && /JUI-comm/
$UI_DISREGARDS = !true
class ShutupyUI
  include Isi::FreeChat::FreeChatUI
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
  
if ARGV.any? {|h| h == '-h' or h == '--help' or h == '-?' } then
  puts "args: Self1 Port1 Self2 Port2 Case", 'In fact only Self1 is used and Case must always be 1'
  exit
end
Self1, Port1, Self2, Port2, Case = ARGV[0..4]
Eva = 'Ευανθια'

# Make my UI
Main_id = 'Juumala'
Main_ui = ShutupyUI::new(:id => Main_id)

Yksi_id = Self1.encode 'utf-8'
#Kaksi_id = Self2.encode 'utf-8'

case Case
when '2' then
  # Start 2
#  Main_ui.m "Starting #{Self2} to port #{Port2}"
#  Kaksi_ui = ShutupyUI::new(:id => Kaksi_id)
#  Kaksi_b = Bitch::new Kaksi_id, Kaksi_ui
#  Kaksi_jui_mh = JUICommunicator::new(Port2)
#  Kaksi_b.add_message_handler Kaksi_jui_mh
#  Kaksi_b.link.buddy_connectable Yksi_id
#  # Manual send to Yksi
#  Kaksi_b.mc.send_message(Kaksi_b.mc.create_message(STM_MESSAGE, RCP => Yksi_id,
#      FRM => Kaksi_id, CNT => 'Hello bobakla'))
else
  # Start 1
  Main_ui.m "Starting #{Self1} to port #{Port1}"
  Yksi_ui = Class::new {include Isi::FreeChatUI::ConsoleUI}::new(
      :id => Yksi_id,
      :b => Isi::FreeChat::FreeChatUI::FINEST) #ShutupyUI::new(:id => Yksi_id)
  Yksi_ui.start
  Yksi_b  = Bitch::new Yksi_id, Yksi_ui
  Yksi_ui.bitch_interpreter = Isi::FreeChatUI::ConsoleUI::SystemInterpreters::
      BitchInterpreter::new(Yksi_b, Yksi_ui.method(:windows))
  Yksi_ui.bitch = Yksi_b
  Yksi_b.start
end

#puts "THE END"

until Yksi_ui.exit? do sleep 1 end

rescue Exception => e
  puts "#{e.class} :: #{e}"
  puts e.backtrace.map {|s| "    #{s}" }.join("\n")
end