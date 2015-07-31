FROM ppas93_base:7.1
MAINTAINER vibhor.aim@gmail.com
ADD ppas_93_sysconfig /etc/sysconfig/ppas/ppas-9.3
RUN service ppas-9.3 initdb
ADD pg_conf/pg_hba.conf /var/lib/ppas/9.3/data/pg_hba.conf
ADD pg_conf/postgresql.conf /var/lib/ppas/9.3/data/postgresql.conf
COPY ppas_env.sh /etc/profile.d/ppas_env.sh
CMD service ppas-9.3 start
CMD echo starting SSH server in foreground
CMD /usr/sbin/sshd -D
