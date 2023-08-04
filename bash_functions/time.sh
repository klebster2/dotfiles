#!/bin/bash

s2hms() {
	# seconds to hours minutes seconds
	awk '{SUM+=$1} END {printf"%d:%d:%d\n", SUM/3600, SUM%3600/60, SUM%60}'
}

s2hms_v() {
	# seconds to hours minutes seconds (the verbose version)
	awk '{SUM+=$1}END{printf "S: %d\nH:M:S: %d:%d:%d\n",SUM,SUM/3600,SUM%3600/60,SUM%60}'
}

sum_time() {
	xargs soxi -D \
	  | awk '{SUM+=$1} END {printf"%d:%d:%d\n", SUM/3600, SUM%3600/60, SUM%60}'
}

hms2s() {
	awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }'
}

