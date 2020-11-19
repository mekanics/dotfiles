#!/bin/bash
RED='#[fg=colour1]'
YELLOW='#[fg=colour3]'
GREEN='#[fg=colour2]'

BATT=$(pmset -g batt)

POWER=$(echo $BATT | grep -Eo "(AC|Battery)\ Power")
POWER_ICON=""
if [ "$POWER" == "AC Power" ]; then
    POWER_ICON="🔌"
elif [ "$POWER" == "Battery Power" ]; then
    POWER_ICON="🔋"
fi

PERCENTAGE=$(echo $BATT | grep -o "[0-9]\+%")
PERC_NUM=${PERCENTAGE//[^0-9]/}

COLOR=$RED
if [ $PERC_NUM -gt 20 ]; then
    COLOR=$GREEN
elif [ $PERC_NUM -gt 5 ]; then
    COLOR=$YELLOW
fi

echo ${POWER_ICON} ${COLOR}${PERCENTAGE}
