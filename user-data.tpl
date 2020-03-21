#!/bin/sh

/usr/bin/yum install -y https://repo.saltstack.com/py3/amazon/salt-py3-amzn2-repo-latest.amzn2.noarch.rpm
/usr/bin/yum clean expire-cache
/usr/bin/yum install -y salt-minion

cat << EOF > /etc/salt/minion.d/jenkins.conf
file_client: local
file_roots:
  base:
    - /usr/local/jenkins/salt/statefiles
grains:
  roles:
    - jenkins-master
EOF

systemctl disable salt-minion
systemctl stop salt-minion

/usr/bin/yum -y install git
/usr/bin/yum -y install jq

/usr/bin/git clone https://github.com/finnjitsu/jenkins.git /usr/local/jenkins
/usr/bin/salt-call --local state.apply

/usr/bin/yum -y update
/sbin/reboot