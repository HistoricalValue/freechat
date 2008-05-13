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

bitch = Isi::FreeChat::Protocol::Bitch::Bitch.new 'Isi'
bitches = Hash['Isi', bitch]

# create a new bitch for each person in the addr book
bitch.bbq.each { |id, addresses| 
  bitches[id] = Isi::FreeChat::Protocol::Bitch::Bitch.new id unless id == 'Isi'
}
for name, bitch in bitches do puts "Closing down #{name}"; bitch.bye end

puts "THE END"