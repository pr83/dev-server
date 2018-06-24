FROM gitlab/gitlab-ce:11.0.0-rc13.ce.0

RUN apt update && \
	apt install -y ssmtp

COPY run.sh /assets/run.sh

VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab", "/etc/ssmtp"]

CMD ["/bin/bash", "/assets/run.sh"]