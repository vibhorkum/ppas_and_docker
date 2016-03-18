FROM ppas95:latest
MAINTAINER richard.yen@enterprisedb.com

ARG INSTALLER_FILENAME

ENV PGDATA=/var/lib/ppas/9.5/data

# Put SSL certs in place
COPY server.crt ${PGDATA}/
COPY server.key ${PGDATA}/
COPY server.req ${PGDATA}/
RUN chown enterprisedb:enterprisedb ${PGDATA}/*

RUN sed -i "s/^#ssl/ssl/" ${PGDATA}/postgresql.conf
RUN echo "host all all ::1/0 trust" >> ${PGDATA}/pg_hba.conf

COPY ${INSTALLER_FILENAME} /tmp
RUN chmod 755 /tmp/${INSTALLER_FILENAME}
COPY install_pem_agent.sh /tmp

RUN service ppas-9.5 restart &> /dev/null
