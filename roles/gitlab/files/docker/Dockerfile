FROM gitlab/gitlab-ce:11.0.0-rc13.ce.0

RUN apt update && \
	apt install -y ssmtp

VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab", "/etc/ssmtp"]