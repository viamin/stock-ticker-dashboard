#!/bin/bash
tmux new-session -d -s ngrok_session "ngrok http --url=ethical-lucky-raptor.ngrok-free.app 443"
