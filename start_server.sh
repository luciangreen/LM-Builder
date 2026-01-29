#!/bin/bash
# Startup script for LM-Builder Prolog Web Server

echo "Starting LM-Builder Prolog Web Server..."
echo "Server will be available at http://localhost:8080"
echo "Press Ctrl+C to stop the server"
echo ""

swipl -g "consult('server.pl'), start_server(8080)" -t 'halt'
