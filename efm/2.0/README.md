Simple Docker image for EnterpriseDB Failover Manager 2.0 on PostgresPlus Advanced Server 9.4

1. Update repos with a valid EDB YUM repo login/password
1. Build image with `docker build -t "my:tag" .`
1. Create container with `docker run --privileged=true  --interactive=false -dtP --name="my_container_name" "my:tag"`
1. Repeat Steps 1-3 again for a Standby container and for a Witness container
1. SSH into the Standby container `docker exec -it my_container_name "/bin/bash"`
1. Set up streaming replication with `/usr/ppas-9.4/bin/create_standby.sh`
1. Exit out of the Standby container and SSH into the Witness container
1. Set Witness container to be Witness node by running `/usr/efm-2.0/bin/set_as_witness.sh`
1. Start up EFM on all nodes
