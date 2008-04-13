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