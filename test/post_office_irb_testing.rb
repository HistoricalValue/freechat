require 'isi/lib'
require 'isi/freechat'
require 'socket'

include Isi::FreeChat::PostOffice

def start port=12000
  mya = Address.new '127.0.0.1', port
  $st = {
    :addr => mya,
    :po   => PostOffice.new(mya)
  }
end

def bye
  $st[:po].close_down
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

