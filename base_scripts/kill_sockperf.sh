#!/usr/bin/bash

sudo kill $(ps -e | grep sockperf | awk '{print $1}')