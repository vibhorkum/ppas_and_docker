Collection of Dockerfiles to build images for EDB Postgres Advanced Server (EPAS)

# Getting Started
* Some of these Dockerfiles are dependent upon access to the EDB Yum repository; you'll need to first get access to those.  Email `support@enterprisedb.com` for access
* Make sure your `~/.bash_profile` has the necessary variables in your environment (unless you're comfortable seeing your passwords in plaintext):
```
export YUMUSERNAME="my-yum-username"
export YUMPASSWORD="1234567890abcdef1234567890"
```
* Once you get your login/password, you can build images based off EDB products:
  * `cd 9.5`
  * `docker build --build-arg YUMUSERNAME=${YUMUSERNAME} --build-arg YUMPASSWORD=${YUMPASSWORD} -t epas95:latest .`
* If you do not have access to the EDB Yum repository, but have downloaded one of our `*.run` installers, you may opt to use the Dockerfile.installer_template file instead.  Edit it and build with the following example command:
  * `cp Dockerfile.installer_template 9.3/Dockerfile`
  * `cd 9.3`
  * Edit `Dockerfile` and fill in `${PGMAJOR}`
  * `docker build --build-arg INSTALLER_FILENAME=postgresplusas-9.3.5.14-1-linux-x64.run -t ppas93:9.3.5 .`
