#!/bin/bash

FILE="$1"

openssl x509 -in "$FILE" -text -noout
