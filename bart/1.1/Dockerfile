FROM epas95:latest
MAINTAINER richard.yen@enterprisedb.com

RUN rpm -ivh http://yum.enterprisedb.com/reporpms/enterprisedb-tools-repo-1.0-1.noarch.rpm
RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/enterprisedb-tools.repo

# run update and install require packages.
RUN yum -y install edb-bart-1.1.0-1.rhel6

# put basic test script in enterprisedb's Linux homedir
COPY bart_test.sh /var/lib/ppas/bart_test.sh

# set custom BART script
COPY bart.cfg /usr/edb-bart-1.1/etc/bart.cfg

CMD service ppas-9.5 start && tail -F /var/log/messages
