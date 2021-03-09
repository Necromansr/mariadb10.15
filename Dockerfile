FROM centos:7
MAINTAINER necromanqq <necromanqq@test.com>

RUN echo -e "[mariadb]\nname = MariaDB\nbaseurl = http://yum.mariadb.org/10.4/centos7-amd64\nenabled = 1\ngpgkey = https://yum.mariadb.org/RPM-GPG-KEY-MariaDB\ngpgcheck = 1"  > /etc/yum.repos.d/MariaDB.repo

RUN rpmkeys --import https://www.percona.com/downloads/RPM-GPG-KEY-percona && \ 
	yum -y install https://mirrors.cloud.tencent.com/percona/release/7/RPMS/noarch/percona-release-1.0-9.noarch.rpm

RUN yum install -y which MariaDB-server MariaDB-client socat MariaDB-backup percona-xtrabackup percona-toolkit && \
	yum clean all 

ADD my.cnf /etc/my.cnf
VOLUME /var/lib/mysql

COPY entrypoint.sh /entrypoint.sh
COPY report_status.sh /report_status.sh
COPY healthcheck.sh /healthcheck.sh
COPY jq /usr/bin/jq
RUN chmod a+x /usr/bin/jq

EXPOSE 3306 4567 4568 4444
ONBUILD RUN yum update -y
HEALTHCHECK --interval=10s --timeout=3s --retries=15 \
	CMD /bin/sh /healthcheck.sh || exit 1

ENTRYPOINT ["/entrypoint.sh"]