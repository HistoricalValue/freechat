$isi = nil
require 'isi/lib'
require 'isi/freechat'
require 'socket'

include Isi::FreeChat::PostOffice

def start port=12000, port2=port+1
  mya = Address.new '127.0.0.1', port
  otha = Address.new '127.0.0.1', port2
  $st = {
    :addr  => mya,
    :po    => PostOffice.new(mya),
    :addr2 => otha,
    :po2   => PostOffice.new(otha)
  }
end

def bye
  $st[:po].close_down
  $st[:po2].close_down
end

def c
  $s = TCPSocket.new $st[:addr].ip, $st[:addr].port
end

def len; "\x0a\x00\x00\x00enadyotria" end
def w;
  $s.write len[0..0]
  sleep 2
  $s.write len[1..2]
  sleep 2
  $s.write len[3..5]
  sleep 2
end
def w_; $s.write len[5..len.length] end

def ww; $s.write len end

def talk
  $st[:po].send_to($st[:addr2], (''.encode('utf-8')<<10<<0<<0<<0<<'abdfgstare'))
  $st[:po].send_to($st[:addr2], len)
end


