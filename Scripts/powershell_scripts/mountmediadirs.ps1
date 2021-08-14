$USER = "USERNAME"
$PASS = "PASSWORD"
net use * /delete /yes
net use M: \\hostname\dir /user:$USER $PASS /persistent:yes
net use D: \\hostname\dir /user:$USER $PASS /persistent:yes