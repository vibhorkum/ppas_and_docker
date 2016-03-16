FROM ppas95:latest
MAINTAINER richard.yen@enterprisedb.com

ARG YUMUSERNAME
ARG YUMPASSWORD

RUN rpm -ivh http://yum.enterprisedb.com/reporpms/enterprisedb-tools-repo-1.0-1.noarch.rpm
RUN sed -i "s/<username>:<password>/${YUMUSERNAME}:${YUMPASSWORD}/" /etc/yum.repos.d/enterprisedb-tools.repo

# run update and install require packages.
RUN yum -y install which ppas95-server-sslutils openssl-devel pem-agent

RUN cp /usr/pem-6.0/etc/agent.cfg.sample /usr/pem-6.0/etc/agent.cfg
RUN sed -i "s/pem_host=.*/pem_host=%%PEM_SERVER_IP%%/" /usr/pem-6.0/etc/agent.cfg
RUN sed -i "s/pem_port=.*/pem_port=5432/" /usr/pem-6.0/etc/agent.cfg
RUN sed -i "s/agent_id=.*/agent_id=%%AGENT_ID%%/" /usr/pem-6.0/etc/agent.cfg

# Create script to register agent
RUN echo "/usr/pem-6.0/bin/pemagent --register-agent --pem-server %%PEM_SERVER_IP%% --pem-user enterprisedb --display-name %%AGENT_NAME%%" >> /tmp/register_pem_agent.sh
RUN chmod 755 /tmp/register_pem_agent.sh
