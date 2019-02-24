#!/bin/sh
curl -sL localhost:${HTTP_PORT} | grep "${VERSION} - Installation"
