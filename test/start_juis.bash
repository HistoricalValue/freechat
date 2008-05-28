#!/bin/bash

JUIHOME=$HOME/NetBeansProjects/FreeChatJUI/dist/
JUI=$JUIHOME/FreeChatJUI.jar
PORT1=4000
PORT2=4001
ME1=Isi
ME2=Chandra #Ευανθια

# Start two JUIS listening in PORT1 and PORT2 for ME1 and ME2
java -jar $JUI $ME1 $PORT1  &
java -jar $JUI $ME2 $PORT2  &
