# create-macvlan
Shell script that creates a Docker MacVlan and checks the functionality of the created MacVLan on a recurring basis.

## Installation instructions
1. Copy the script "activate-macvlan.sh” to your Docker host.
2. In the script, adjust the variables `DOCKERPATH`, `SUBNET`, `IPRANGE`, `GATEWAY`, `ADAPTER` and `NETWORKNAME` to your Docker environment.
3. Make the file executable with `sudo chm̀od +x activate-macvlan.sh`.
4. Führte das Script mit `sudo sh activate-macvlan.sh` aus.

## Further interesting information
After installation, the script periodically checks the Docker macvlan and the promiscuous mode.
Check the log file and interrupt it with `ctrl c` if required.

**Attention:** promiscuous mode must be executed again after each restart.
Set up a service for the script so that promiscuous mode is activated after the restart and the macvlan is checked regularly.
