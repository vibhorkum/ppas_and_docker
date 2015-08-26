# ppas_and_docker

This is a simple repository to enable the Support team to use Docker on their Macs, using boot2docker.  For now, these are based off the EDB yum repository, using CentOS as the base operating system.  In the future, other permutations will be added to this repository, and will be expanded to include native Docker support (not using boot2docker) on Linux systems

## Setting up
- First, you'll need to install boot2docker on your Mac ([http://boot2docker.io/])
- Next, clone this repo and navigate to a base directory (i.e., `./ppas_and_docker/base/centos-6.6/9.1`)
- Build an image using `docker build -t ppas91_base:6.6 .`
- You may wish to stop here if you want to start up a container on your own, or continue along if you want Docker to start up a container and PPAS for you
- Navigate to the corresponding ppas directory (i.e., `./ppas_and_docker/ppas/centos-6.6/9.1`)
- Build an image and a container using `docker build -t ppas91:6.6 .`
- Done! You may also want to look at the `docker_functions` file for some useful shortcuts.  Load them into your shell environment with `. ./docker_functions`

### Enjoy!
