#!/usr/bin/bash

sudo kill $(ps -e | grep iperf3 | awk '{print $1}')