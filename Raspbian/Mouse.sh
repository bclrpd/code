#! /bin/bash
while true ; do
Position=$(xdotool getmouselocation)
IFS=" " read x y screen window<<< "$Position"
x=$(echo "$x" | sed 's/x://')
y=$(echo "$y" | sed 's/y://')
#echo $x
if [ $x -gt 1024 ] ; then
	xdotool mousemove 1023 $y
fi

sleep 0.01
done
