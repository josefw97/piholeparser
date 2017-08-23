#!/bin/bash
## Check File size

## Variables
script_dir=$(dirname $0)
SCRIPTVARSDIR="$script_dir"/../../scriptvars/
STATICVARS="$SCRIPTVARSDIR"staticvariables.var
if
[[ -f $STATICVARS ]]
then
source $STATICVARS
else
echo "Static Vars File Missing, Exiting."
exit
fi
if
[[ -f $TEMPPARSEVARS ]]
then
source $TEMPPARSEVARS
else
echo "Temp Parsing Vars File Missing, Exiting."
exit
fi

if
[[ -f $BPARSEDFILETEMP ]]
then
PARSEDFILESIZEBYTES=$(stat -c%s "$BPARSEDFILETEMP")
echo "PARSEDFILESIZEBYTES="$PARSEDFILESIZEBYTES"" | tee --append $TEMPPARSEVARS &>/dev/null
PARSEDFILESIZEKB=`expr $PARSEDFILESIZEBYTES / 1024`
echo "PARSEDFILESIZEKB="$PARSEDFILESIZEKB"" | tee --append $TEMPPARSEVARS &>/dev/null
PARSEDFILESIZEMB=`expr $PARSEDFILESIZEBYTES / 1024 / 1024`
echo "PARSEDFILESIZEMB="$PARSEDFILESIZEMB"" | tee --append $TEMPPARSEVARS &>/dev/null
fi

timestamp=$(echo `date`)

if 
[[ -f $BPARSEDFILETEMP && "$PARSEDFILESIZEBYTES" -eq 0 ]]
then
printf "$red"  "Current Parsing Method Emptied File. It will be skipped in the future."
timestamp=$(echo `date`)
echo "* $BASEFILENAME List Was Killed By The Parsing Process. It will be skipped in the future. $timestamp" | tee --append $RECENTRUN &>/dev/null
mv $FILEBEINGPROCESSED $KILLTHELIST
echo "* $BASEFILENAME List Was An Empty File After Download. $timestamp" | tee --append $RECENTRUN &>/dev/null
rm $BPARSEDFILETEMP
elif
[[ -f $BPARSEDFILETEMP && "$PARSEDFILESIZEBYTES" -gt 0 ]]
then
PARSEDFILESIZENOTZERO=true
echo "PARSEDFILESIZENOTZERO="$PARSEDFILESIZENOTZERO"" | tee --append $TEMPPARSEVARS &>/dev/null
fi

## File size
if
[[ -n $PARSEDFILESIZENOTZERO && "$PARSEDFILESIZEMB" -gt 0 && "$PARSEDFILESIZEKB" -gt 0 && "$PARSEDFILESIZEBYTES" -gt 0 ]]
then
printf "$yellow"  "Size of $BASEFILENAME = $PARSEDFILESIZEMB MB."
elif
[[ -n $PARSEDFILESIZENOTZERO && "$PARSEDFILESIZEMB" -eq 0 && "$PARSEDFILESIZEKB" -gt 0 && "$PARSEDFILESIZEBYTES" -gt 0 ]]
then
printf "$yellow"  "Size of $BASEFILENAME = $PARSEDFILESIZEKB KB."
elif
[[ -n $PARSEDFILESIZENOTZERO && "$PARSEDFILESIZEMB" -eq 0 && "$PARSEDFILESIZEKB" -eq 0 && "$PARSEDFILESIZEBYTES" -gt 0 ]]
then
printf "$yellow"  "Size of $BASEFILENAME = $PARSEDFILESIZEBYTES Bytes."
fi

## How Many Lines
if
[[ -n $PARSEDFILESIZENOTZERO && "$PARSEDFILESIZEBYTES" -gt 0 ]]
then
PARSEDHOWMANYLINES=$(echo -e "`wc -l $BPARSEDFILETEMP | cut -d " " -f 1`")
echo "PARSEDHOWMANYLINES="$PARSEDHOWMANYLINES"" | tee --append $TEMPPARSEVARS &>/dev/null
printf "$yellow"  "$PARSEDHOWMANYLINES Lines After Download."
fi