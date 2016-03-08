This is a repository of Dockerfiles and demo files to quickly set up development/testing/demo instances of EDB products.  In each of the products' directories, you should find a demo file, which should be almost executable right out of the box.

# Getting Started
* Since these Dockerfiles are dependent upon access to the EDB Yum repository, you'll need to first get access to it.  Email support@enterprisedb.com for access
* Once you get your login/password, you can build images based off EDB products:
  * `cd ppas95`
  * `docker build --build-arg YUMUSERNAME=<username> --build-arg YUMPASSWORD=<password -t ppas95:latest .`
* Depending on which product you're planning to use, you may need to add your enterprisedb.com login and password to the `{product_name}_demo.sh` file, so that the installers can use your credentials to fetch license and installation information
* If you do not have access to the EDB Yum repository, but have downloaded one of our installers, you may opt to use the Dockerfile.installer_template file instead.  Edit it and build with the following example command:
  * `docker build --build-arg INSTALLER_FILENAME=postgresplusas-9.3.5.14-1-linux-x64.run -t ppas93:9.3.5 .`

# docker_functions
`docker_functions` is a set of bash functions that are intended to make administration via Docker super-easy.  It's recommended that you add it to your terminal environment like so `echo ". /path/to/docker_functions" >> ~/.bash_profile`
