juju ssh mysql/2 sudo systemctl poweroff
sleep 60
juju ssh mysql/1 sudo systemctl poweroff
sleep 60
juju ssh mysql/0 sudo systemctl poweroff
sleep 60

juju ssh 0 sudo systemctl poweroff
juju ssh 1 sudo systemctl poweroff
juju ssh 2 sudo systemctl poweroff
juju ssh 3 sudo systemctl poweroff
juju ssh 4 sudo systemctl poweroff
juju ssh 5 sudo systemctl poweroff
juju ssh 6 sudo systemctl poweroff
juju ssh 7 sudo systemctl poweroff
juju ssh 8 sudo systemctl poweroff
juju ssh 9 sudo systemctl poweroff
juju ssh 10 sudo systemctl poweroff
juju ssh 11 sudo systemctl poweroff
juju ssh 12 sudo systemctl poweroff
juju ssh -m controller 0 sudo systemctl poweroff
ssh ubuntu@192.168.10.2 sudo systemctl poweroff
