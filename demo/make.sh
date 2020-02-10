#!/bin/sh


case $1 in

  -d)  elm make --debug src/Main.elm --output=public/Main.js
       ;;

  *) elm make --optimize src/Main.elm --output=public/Main.js
       ;;

esac

