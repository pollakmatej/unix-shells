#
var=reboot
if $var; then
echo "neeeeeeeeh rebootiiing!"
fi
#
var=reboot \
if [ $var ]; then \
echo "neeeeeeeeh rebootiiing!, nope because [] :D" \
fi