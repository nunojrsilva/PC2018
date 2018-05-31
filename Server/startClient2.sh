#!/usr/bin/expect
# Starts Client 2
spawn telnet localhost 12345
send "*create_account ent 123456\n"
interact
