# encoding: UTF-8
$isi = {
  :debug_hello => !true,
  :debug_bye =>   !true,
}
$ENV = ENV
$:.unshift('trunk')
require 'isi/freechat'
include Isi, Isi::FreeChat, Isi::FreeChat::Protocol::MessageCentre::MessageTypes

$UI_LEVEL = FreeChatUI::INFO
class ShutupyUI < Isi::FreeChat::FreeChatUI
  def initialize id, main_on=true, main_level=$UI_LEVEL
    @id = id
    @main_on = main_on
    @main_level = main_level
  end
  attr_accessor :main_on
  def main_on?
    main_on
  end
  def default_print_message_from(from, level, msg)
    super(from, level, "(#{@id})__--``--__ #{msg}") if level <= $UI_LEVEL
  end
  def main(level,msg)
    default_print_message_from('main', level, msg) if main_on?
  end
  def m(msg)
    main(@main_level, msg)
  end
end

Isi_id = 'Isi'; Ευανθια_id = 'Ευανθια'
Isi_ui = ShutupyUI.new Isi_id; Ευανθια_ui = ShutupyUI.new Ευανθια_id
Main_ui = ShutupyUI.new 'main', true, FreeChatUI::FINE
Isi_ = Isi::FreeChat::Protocol::Bitch::Bitch.new(Isi_id, Isi_ui)
Ευανθια = Isi::FreeChat::Protocol::Bitch::Bitch.new(Ευανθια_id, Ευανθια_ui)
bitches = Hash[Isi_id, Isi_, Ευανθια_id, Ευανθια]

# Isi says hi to Ευανθια
Isi_.po.send_to(
    Isi_.link.get_address_of(Ευανθια_id, 0),
    Isi_.mc.create_message(STM_MESSAGE, CNT =>'screw you, Ευανθια, we are over',
        RCP => Ευανθια_id, FRM => Isi_id).serialise)
# wait for it...
3.downto(1) { |i| Main_ui.m("replying in #{i}..."); sleep 1 }
# Ευανθια says hello to isi
Ευανθια.po.send_to(
    Ευανθια.link.get_address_of(Isi_id, 0),
    Ευανθια.mc.create_message(STM_HELLO, RCP => Isi_id).serialise)

Main_ui.m "Hit enter to close down"
not_ok = true
begin
  STDIN.read_nonblock(1)
  not_ok = false
rescue Errno::EAGAIN, Errno::EWOULDBLOCK
  sleep 1
end while not_ok

for name, bitch in bitches do
  Main_ui.main(FreeChatUI::DEBUG, "Closing down #{name}")
  bitch.bye
end

puts "THE END"