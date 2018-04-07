#!/bin/ksh
MACHINE=`hostname`
CDATE=`date +%Y-%m-%d_%H:%M:%S`

echo "# DEVICES INFO" > $MACHINE_$CDATE.txt
echo ""
pvs >> $MACHINE_$CDATE.txt
lvs >> $MACHINE_$CDATE.txt
vgs >> $MACHINE_$CDATE.txt
echo ""

echo "# iostat -dx 60 60"
iostat -dx 60 60