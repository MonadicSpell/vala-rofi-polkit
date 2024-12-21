#!/usr/env/bin bash

MSG_THEME='entry { enabled: false; } inputbar { children: [ "prompt"]; }'

if [[ "$1" = "auth" ]]; then
  res="$(printf '' | rofi  -dmenu -p "$2" -mesg "$3" -password -no-fixed-num-lines)"

  if [[ -z $res ]]; then
    echo "cancel"
  else
    echo password "$res"
  fi
else
  rofi -theme-str "$MSG_THEME" -no-fixed-num-lines -dmenu -p "$1:" -mesg "$2"
fi
