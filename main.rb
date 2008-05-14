$isi = {
  :debug_hello => !true,
  :debug_bye =>   !true,
}
$ENV = ENV

require 'trunk/isi/freechat'
include Isi, Isi::FreeChat, Isi::FreeChat::Protocol::MessageCentre::MessageTypes

class ShutupyUI < Isi::FreeChat::FreeChatUI
  def initialize main_on=true, main_level=INFO
    @main_on = main_on
    @main_level = main_level
  end
  attr_accessor :main_on
  def main_on?
    main_on
  end
  def default_print_message_from(from, level, msg)
    super(from, level, msg) if level <= INFO
  end
  def main(level,msg)
    default_print_message_from('main', level, msg) if main_on?
  end
  def m(msg)
    main(@main_level, msg)
  end
end

Ui = ShutupyUI.new
Isi_id = 'Isi'; Chandra_id = 'Chandra'
Isi_ = Isi::FreeChat::Protocol::Bitch::Bitch.new(Isi_id, Ui)
Chandra = Isi::FreeChat::Protocol::Bitch::Bitch.new(Chandra_id, Ui)
bitches = Hash[Isi_id, Isi_, Chandra_id, Chandra]

# Chandra says hello to isi
Chandra.po.send_to(
    Chandra.link.get_address_of(Isi_id, 0),
    Chandra.mc.create_message(STM_HELLO, 'rcp' => Isi_id).serialise)
# Isi says hi back
Isi_.po.send_to(
    Isi_.link.get_address_of(Chandra_id, 0),
    Isi_.mc.create_message(STM_MESSAGE, 'cnt' => 'screw you, chandra, we are over',
        'rcp' => Chandra_id, 'frm' => Isi_id).serialise)

Ui.m "Hit enter to close down"
not_ok = true
begin
  STDIN.read_nonblock(1)
  not_ok = false
rescue Errno::EAGAIN, Errno::EWOULDBLOCK
  sleep 1
end while not_ok

for name, bitch in bitches do
  Ui.main(FreeChatUI::DEBUG, "Closing down #{name}")
  bitch.bye
end

puts "THE END"