Simple Docker image for EnterpriseDB Postgres Enterprise Manager (PEM) on EDB Postgres Advanced Server (EPAS)

1. Be sure to build an EPAS image from which this Dockerfile can build.  If you need help with that, you can visit the `../epas` folder
1. Build image with `docker build --build-arg YUMUSERNAME=${YUMUSERNAME} --build-arg YUMPASSWORD=${YUMPASSWORD} -t "my:tag" .`
1. If you do not have access to the EDB Yum repository, but have downloaded a `*.run` installer, you may build your image with:
  * `cd server/5.0`
  * Edit the variables in `Dockerfile` as necessary
  * `docker build --build-arg EDBUSERNAME=${EDBUSERNAME} --build-arg EDBPASSWORD=${EDBPASSWORD} --build-arg INSTALLER_FILENAME="pem_server-5.0.3-4-linux-x64.run" -t pem5_server:5.0.3 .`
1. Do the same with `agent/`
1. Create container with `docker run --privileged=true  --interactive=false -dtP --name="my_container_name" "my:tag"`
1. SSH into the container you wish to be the PEM server `docker exec -it my_container_name "/bin/bash"`
1. Edit `/tmp/install_pem_agent.sh` and fill in the `${OTHER_MASTER_IPS}` variable accordingly
1. Run `/tmp/install_pem_agent.sh` within the container designated as the PEM server
1. Test and verify the PEM Server is running by visiting `https://docker_ip_address:port_exposed_for_8443/pem`
1. Add and verify agents as desired

If you wish to automatically build a demo environment, you can run `./pem_demo.sh` -- be sure to edit the script and fill in the correct image names first.
