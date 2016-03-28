This is a repository of Dockerfiles and demo files to quickly set up development/testing/demo instances of EDB products.  In each of the products' directories, you should find a demo file, which should be almost executable right out of the box.

# Getting Started
* Some of these Dockerfiles are dependent upon access to the EDB Yum repository; you'll need to first get access to those.  Email `support@enterprisedb.com` for access
* Make sure your `~/.bash_profile` has the necessary variables in your environment (unless you're comfortable seeing your passwords in plaintext):
```
export EDBUSERNAME="john.doe@enterprisedb.com"
export EDBPASSWORD="abc123"
export YUMUSERNAME="my-yum-username"
export YUMPASSWORD="1234567890abcdef1234567890"
```

* Once you get your login/password, you can build images based off EDB products:
  * `cd epas/9.5`
  * `docker build --build-arg YUMUSERNAME=${YUMUSERNAME} --build-arg YUMPASSWORD=${YUMPASSWORD} -t epas95:latest .`
* If you do not have access to the EDB Yum repository, but have downloaded one of our `*.run` installers, you may opt to use the Dockerfile.installer_template file instead.  Edit it and build with the following example command:
  * `cd epas`
  * `cp Dockerfile.installer_template 9.3/Dockerfile`
  * `cd 9.3`
  * Edit `Dockerfile` and fill in `${PGMAJOR}`
  * `docker build --build-arg INSTALLER_FILENAME=postgresplusas-9.3.5.14-1-linux-x64.run -t ppas93:9.3.5 .`
* Based on the Dockerfile for some products, you may need to include your EDB login credentials:
  * `cd xdb/5.1`
  * `docker build --build-arg EDBUSERNAME=${EDBUSERNAME} --build-arg EDBPASSWORD=${EDBPASSWORD} --build-arg INSTALLER_FILENAME="xdbreplicationserver-5.1.8-1-linux-x64.run" -t xdb5:5.1.8 .`
* If you'd like to deploy a sample environment of one of our products, feel free to execute the corresponding `{product_name}_demo.sh` file; you may need to edit the file first, to make sure you're grabbing the right image(s).

# docker_functions
`docker_functions` is a set of bash functions that are intended to make administration via Docker super-easy.  It's recommended that you add it to your terminal environment like so `echo ". /path/to/docker_functions" >> ~/.bash_profile`
