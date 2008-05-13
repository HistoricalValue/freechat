$isi = {
  :debug_hello => !true,
  :debug_bye =>   !true,
}
$ENV = {}
`env`.gsub("\\\n", '').each_line { |l|
  k, v = l.chomp!.split('=', 2)
  $ENV[k] = v
}

require 'trunk/isi/freechat'

bitch = Isi::FreeChat::Protocol::Bitch::Bitch.new
p bitch

puts "THE END"