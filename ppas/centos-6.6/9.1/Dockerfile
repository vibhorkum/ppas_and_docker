FROM ppas91_base:6.6
MAINTAINER vibhor.aim@gmail.com
ADD ppas_91_sysconfig /etc/sysconfig/ppas/ppas-9.1
RUN service ppas-9.1 initdb
ADD pg_conf/pg_hba.conf /var/lib/ppas/9.1/data/pg_hba.conf
ADD pg_conf/postgresql.conf /var/lib/ppas/9.1/data/postgresql.conf
COPY ppas_env.sh /etc/profile.d/ppas_env.sh
CMD service ppas-9.1 start
CMD echo starting SSH server in foreground
CMD /usr/sbin/sshd -D
