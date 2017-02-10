#!/bin/sh

echo `hostapd_cli signature $1` | cut -d "'" -f 3- | cut -d ' ' -f 2-

