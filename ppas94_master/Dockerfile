FROM ppas:94
MAINTAINER vibhor.aim@gmail.com
ADD ppas_94_sysconfig /etc/sysconfig/ppas/ppas-9.4
RUN service ppas-9.4 initdb
ADD pg_conf/pg_hba.conf /var/lib/ppas/9.4/data/pg_hba.conf
ADD pg_conf/postgresql.conf /var/lib/ppas/9.4/data/postgresql.conf
COPY ppas_env.sh /etc/profile.d/ppas_env.sh
CMD service ppas-9.4 start; echo starting SSH server in foreground;  /usr/sbin/sshd -D
