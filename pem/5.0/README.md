Docker container to set up a Postgres Enterprise Manager (PEM) cluster.
This Dockerfile will install PEM Agent, and also provides a simple script to allow users to install the PEM Server on the container of their choice

###To get started
1. Update repos with a valid EDB YUM repo login/password
1. Build image with `docker build -t "my:tag" .`
1. Create container with `docker run --privileged=true  --interactive=false -dtP --name="my_container_name" "my:tag"`
1. SSH into the container with `docker exec -it my_container_name "/bin/bash"`

###To install PEM Server
1. Update `/root/pem_install_optionfile` with a valid EDB login/password
1. Run the PEM Server installation script: `/root/install_pem_server.sh`
1. Point your browser to `https://${boot2docker IP address}:${exposed 8443 port}/pem
1. Log in with enterprisedb/abc123

###To install PEM Agent
1. Update `/root/install_pem_agent.sh` with the PEM Server IP address, and provide a name for the agent
1. Run the PEM Agent installation script: `/root/install_pem_agent.sh`
