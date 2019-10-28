#!/bin/bash -eu

apt-get install $(awk '{print $1}' apps)
