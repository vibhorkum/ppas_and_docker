Simple Docker image for EnterpriseDB Failover Manager 2.0 on EDB Postgres Advanced Server (EPAS)

###Getting Started
1. Update repos with a valid EDB YUM repo login/password
1. Build image with `docker build --build-arg YUMUSERNAME=${YUMUSERNAME} --build-arg YUMPASSWORD=${YUMPASSWORD} -t "my:tag" .`
1. Create 3 containers with `docker run --privileged=true  --interactive=false -dtP --name="<my_container_name>" "my:tag"`

###Setting up EFM Master node
1. SSH into the master node container `docker exec -it my_container_name "/bin/bash"`
1. Start PPAS and EFM with `/usr/efm-2.0/bin/set_as_master.sh`

###Setting up EFM Standby node(s)
1. SSH into the master node container `docker exec -it my_container_name "/bin/bash"`
1. Add the standby node to the EFM cluster `/usr/efm-2.0/bin/efm add-node efm <standby_ip_address> <priority>`
1. SSH into the standby node container `docker exec -it my_container_name "/bin/bash"`
1. Add the master node's IP address `echo <master_ip>:5430 >> /etc/efm-2.0/efm.nodes`
1. If you have more than one standby, you will need to add each standby's IP address to /etc/efm-2.0/efm.nodes (all in one line, separated by spaces)
1. Start PPAS (including streaming replication) and EFM with `/usr/efm-2.0/bin/set_as_standby.sh`

###Setting up Witness node
1. SSH into the master node container `docker exec -it my_container_name "/bin/bash"`
1. Add the witness node to the EFM cluster `/usr/efm-2.0/bin/efm add-node efm <witness_ip_address> <priority>`
1. SSH into the witness node container `docker exec -it my_container_name "/bin/bash"`
1. Add all other nodes' IP addresses to `/etc/efm-2.0/efm.nodes`
1. Start EFM as Witness by running `/usr/efm-2.0/bin/set_as_witness.sh`

###EFM Demo
If you wish, you can set up a demo EFM environment by simply running the `efm_demo.sh` script.  Once you've updated the script with the correct image name, you should be able to set up a 3-node EFM cluster in seconds:
```
$ time ./efm_demo.sh 
<... churn, churn, churn ...>
Cluster Status: efm

	Agent Type  Address              Agent  DB       Info
	--------------------------------------------------------------
	Master      172.17.0.6           UP     UP        
	Witness     172.17.0.8           UP     N/A       
	Standby     172.17.0.7           UP     UP        

Allowed node host list:
	172.17.0.6 172.17.0.7 172.17.0.8

Standby priority host list:
	172.17.0.8 172.17.0.7

Promote Status:

	DB Type     Address              XLog Loc         Info
	--------------------------------------------------------------
	Master      172.17.0.6           0/401F170        
	Standby     172.17.0.7           0/401F170        

	Standby database(s) in sync with master. It is safe to promote.

real	0m35.864s
user	0m0.362s
sys	0m0.291s
```
