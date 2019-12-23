#!/bin/bash

reposen=curl -s http://localhost/server-status | sed -n '/Server uptime/p'
