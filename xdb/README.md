Simple Docker image for EnterpriseDB xDB on EDB Postgres Advanced Server (EPAS)

1. Be sure to build an EPAS image from which this Dockerfile can build.  If you need help with that, you can visit the `../epas` folder
1. Build image with `docker build --build-arg YUMUSERNAME=${YUMUSERNAME} --build-arg YUMPASSWORD=${YUMPASSWORD} -t "my:tag" .`
1. If you do not have access to the EDB Yum repository, but have downloaded a `*.run` installer, you may build your image with:
  * `cd 5.1`
  * `cp Dockerfile.installer_template Dockerfile`
  * Edit the variables in `Dockerfile` as necessary
  * `docker build --build-arg EDBUSERNAME=${EDBUSERNAME} --build-arg EDBPASSWORD=${EDBPASSWORD} --build-arg INSTALLER_FILENAME="xdbreplicationserver-5.1.8-1-linux-x64.run" -t xdb5:5.1.8 .`
1. Create container with `docker run --privileged=true  --interactive=false -dtP --name="my_container_name" "my:tag"`
1. Get a list of IPs of containers created
1. SSH into the container you wish to be the xDB publication server `docker exec -it my_container_name "/bin/bash"`
1. Edit `/usr/ppas-xdb-5.1/bin/build_xdb_mmr_publication.sh` and fill in the `${OTHER_MASTER_IPS}` variable accordingly
1. Run `/usr/ppas-xdb-5.1/bin/build_xdb_mmr_publication.sh`
1. Test and verify your replication is working

If you wish to automatically build a demo Multi-Master Replication (MMR) or Single-Master Replication (SMR) environment, you can run `./xdb_mmr_demo.sh` or `./xdb_smr_demo.sh` -- be sure to edit the scripts and fill in the correct image names first.

