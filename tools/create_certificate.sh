#!/bin/sh
openssl req -x509 -nodes -newkey rsa:1024 -keyout key.pem -out cert.pem -days 365
