#!/bin/bash
# Starts server
(echo "*create_account ent 123456" && cat) | telnet localhost 12345

