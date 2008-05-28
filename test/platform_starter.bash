#! /bin/bash

JUIHOME=$HOME/NetBeansProjects/FreeChatJUI/dist/
JUI=$JUIHOME/FreeChatJUI.jar
PORT1=4000
PORT2=4001
ME1=Isi
ME2=Chandra #Ευανθια


# Start freechat
ruby -r isi/lib main.rb $ME1 $PORT1 $ME2 $PORT2 1 &
ruby -r isi/lib main.rb $ME1 $PORT1 $ME2 $PORT2 2 &

printf '\n'
