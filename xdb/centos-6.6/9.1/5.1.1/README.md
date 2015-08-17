Simple Docker image for EnterpriseDB xDB 5.1 on PostgresPlus Advanced Server 9.4

1. Update repo files with a valid EDB YUM repo login/password
1. Build image with `docker build -t "my:tag" .`
1. Create container with `docker run --privileged=true  --interactive=false -dtP --name="my_container_name" "my:tag"`
1. Set up other PostgreSQL containers as desired
1. Get a list of IPs of containers created
1. SSH into the container you wish to be the xDB publication server `docker exec -it my_container_name "/bin/bash"`
1. Edit `/build_xdb_publication.sh` accordingly
1. Run `/usr/ppas-xdb-5.1/bin/build_xdb_publication.sh`
1. Test and verify your replication is working
