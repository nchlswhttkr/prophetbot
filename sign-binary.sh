#!/bin/bash

security find-identity -v -p codesigning

PS3="Select the identity to use for code signing > "
select IDENTITY in $(security find-identity -v -p codesigning | grep --extended-regexp --only-matching "[0-9A-F]{40}"); do
    codesign -s "$IDENTITY" /usr/local/bin/prophetbot
    break
done
