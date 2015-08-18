Docker container to set up a Postgres Enterprise Manager (PEM) cluster.
This Dockerfile will install PEM Agent, and also provides a simple script to allow users to install the PEM Server on the container of their choice

To get started:
1. Update repos with a valid EDB YUM repo login/password
1. Build image with `docker build -t "my:tag" .`
1. Create container with `docker run --privileged=true  --interactive=false -dtP --name="my_container_name" "my:tag"`
1. SSH into the container with `docker exec -it my_container_name "/bin/bash"`
1. PEM Agent should be running: `ps aux | grep -i pem`

To install PEM Server:
1. Update `pem_install_optionfile` with a valid EDB login/password
1. Run the PEM Server installation script: `/root/install_pem_server.sh`

