#!/usr/bin/expect
# Starts Client 1
spawn telnet localhost 12345
send "*create_account cli 123456\n"
interact

