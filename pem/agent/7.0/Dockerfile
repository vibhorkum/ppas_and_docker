FROM epas10:latest
MAINTAINER vibhor.aim@gmail.com

ARG EDBUSERNAME
ARG EDBPASSWORD
ARG INSTALLER_FILENAME
ENV PEMHOME="/usr/pem-7.2"

# run update and install require packages.
RUN yum -y install which edb-as10-server-sslutils openssl-devel
RUN service edb-as-10 start

COPY ${INSTALLER_FILENAME} /tmp/${INSTALLER_FILENAME}
RUN chmod 755 /tmp/${INSTALLER_FILENAME}
RUN /tmp/${INSTALLER_FILENAME} --mode unattended --prefix ${PEMHOME} --pghost 172.17.0.3 --pguser enterprisedb --pgpassword abc123
#RUN cp ${PEMHOME}/agent/etc/agent.cfg.sample ${PEMHOME}/agent/etc/agent.cfg
RUN sed -i "s/pem_host=.*/pem_host=%%PEM_SERVER_IP%%/" ${PEMHOME}/agent/etc/agent.cfg
RUN sed -i "s/pem_port=.*/pem_port=5432/" ${PEMHOME}/agent/etc/agent.cfg
RUN sed -i "s/agent_id=.*/agent_id=%%AGENT_ID%%/" ${PEMHOME}/agent/etc/agent.cfg

# Create script to register agent
RUN echo "# For versions prior to 6.0.2, use pemagent instead of pemworker" >> /tmp/register_pem_agent.sh
RUN echo "LD_LIBRARY_PATH=\"${PEMHOME}/agent/lib/:\$LD_LIBRARY_PATH\" ${PEMHOME}/bin/pemworker --register-agent --pem-server %%PEM_SERVER_IP%% --pem-user enterprisedb --display-name %%AGENT_NAME%%" >> /tmp/register_pem_agent.sh
RUN chmod 755 /tmp/register_pem_agent.sh
