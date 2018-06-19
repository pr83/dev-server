FROM gitlab/gitlab-ce:10.3.5-ce.0

RUN apt update && \
	apt install -y ssmtp

VOLUME ["/etc/gitlab", "/var/opt/gitlab", "/var/log/gitlab", "/etc/ssmtp"]