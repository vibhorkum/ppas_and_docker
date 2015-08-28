Simple Docker image for EnterpriseDB Failover Manager 2.0 on PostgresPlus Advanced Server 9.4

###Getting Started
1. Update repos with a valid EDB YUM repo login/password
1. Build image with `docker build -t "my:tag" .`
1. Create container with `docker run --privileged=true  --interactive=false -dtP --name="my_container_name" "my:tag"`

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
