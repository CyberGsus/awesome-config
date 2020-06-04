#!/bin/sh



iface=${1:-[ew]*}

# from https://github.com/LukeSmithxyz/voidrice/pull/674/files

update() {
  sum=0
  for arg; do
    read -r i < "$arg"
    sum=$(( sum + $i ))
  done
  cache=${XDG_CACHE_DIR:-$HOME/.cache}/${1##*/}
  [ -f "$cache" ] && read -r old < "$cache" || old=0
  printf %d\\n "$sum" > "$cache"
  t=bc <<< "scale=7; $(( $sum - $old ))/1024"
  printf "%f\n" "$t"
}


rx=$(update /sys/class/net/$iface/statistics/rx_bytes)
tx=$(update /sys/class/net/$iface/statistics/tx_bytes)

printf "$rx\n$tx"




#vim: ft=sh
