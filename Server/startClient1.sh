#!/bin/bash
# Starts server
(echo "*create_account cli 123456" && cat) | telnet localhost 12345

