#########################################################################
##
## Cluster installer
##
##    * In general we try to make operations idempotent and reversible.
##
##    * Idempotency: Running an operation once should have the same
##      effect as running it ten times.
##
##    * Reversibility: Each operation implements install and clean 
##      sub-operations. The default is to install and clean can be 
##      specified to reverse the ordinary operation.
##
#########################################################################

import os
import socket
from string import Template
from fabric.api import cd
from fabric.api import env
from fabric.api import hosts
from fabric.api import local
from fabric.api import run
from fabric.api import sudo
from fabric.contrib.files import exists

# User identity for remote commands
env.user = 'evryscope'

# Paths
root  = "/projects/stars"
stack = "%s/stack" % root
app   = "%s/app"   % root
dist  = "%s/dist"  % root
conf  = "%s/app/evry/conf" % root

opt   = "/opt/app"
orchestration = "%s/orchestration" % opt

# Third party libraries to install
dist_map = {
    'spark'    : 'http://apache.arvixe.com//spark/spark-1.4.1/spark-1.4.1-bin-hadoop2.6.tgz',
    'scala'    : 'http://www.scala-lang.org/files/archive/scala-2.10.4.tgz',    
    'jdk'      : 'jdk-8u60-linux-x64.tar.gz',
    'maven'    : 'http://download.nextag.com/apache/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz',
    'mongodb'  : 'https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.0.6.tgz',
    'node'     : 'https://nodejs.org/dist/v0.12.7/node-v0.12.7-linux-x64.tar.gz',
    'hadoop'   : 'http://apache.arvixe.com/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz',
    'tachyon'  : 'http://tachyon-project.org/downloads/files/0.7.1/tachyon-0.7.1-bin.tar.gz',
    'swarp'    : 'http://www.astromatic.net/download/swarp/swarp-2.38.0-1.x86_64.rpm'
}

# Apps we want on all machines
base_apps = {
    'python-virtualenv' : 'python-virtualenv',
    'monit-'            : 'monit',
    'git-'              : 'git'
}

# Head nodes - run cluster management software
head_nodes = (
    'stars-c0.edc.renci.org',
    'stars-c1.edc.renci.org'
)
# Worker nodes - will execute jobs
worker_nodes = (
    'stars-c2.edc.renci.org',
    'stars-c3.edc.renci.org',
    'stars-c4.edc.renci.org',
    'stars-c5.edc.renci.org',
    'stars-c6.edc.renci.org',
    'stars-c7.edc.renci.org'
)

# Zookeeper nodes
zookeeper_nodes=( 'stars-c0.edc.renci.org' )

# Head nodes plus workers
cluster_nodes = tuple(list(head_nodes) + list(worker_nodes))

##################################################################
##
## Utilities
##
##################################################################

''' uniformly select install or clean operation based on the mode parameter '''
def execute_op (mode, install, clean):
    installed = True
    if mode == "install":
        install ()
    elif mode == "clean":
        clean ()
        installed = False
    return installed

# Tar

''' Untar a file and create a symbolic link called current to the extracted folder '''
def untar_and_link (name, file_name):
    run ('tar xzf %s/%s' % (dist, file_name))
    run ('ln -s *%s* current' % name)
    run ('ls -lisa')

''' Deploy a tar based on a URI '''
def deploy_uri_tar (mode, name):
    path = "%s/%s" % (stack, name)
    def install ():
        uri = dist_map [name]
        with cd (dist):
            run ('wget --timestamping --quiet %s' % uri)
        run ('mkdir -p %s' % path)
        with cd (path):
            untar_and_link (name, os.path.basename (uri))
    def clean ():
        run ('rm -rf %s' % path)
    return execute_op (mode, install, clean)

''' Deploy an RPM based on a URI '''
def deploy_uri_rpm (mode, name):
    def install ():
        yum_install (mode, name, dist_map [name])
    def clean ():
        yum_install (mode, name, name)
    return execute_op (mode, install, clean)

''' Deploy a tar '''
def deploy_tar (mode, name):
    path = "%s/%s" % (stack, name)
    def install ():
        run ('mkdir -p %s' % path)
        with cd (path):
            untar_and_link (name, dist_map [name])
    def clean ():
        run ('rm -rf %s' % path)
    return execute_op (mode, install, clean)

# Yum

''' Add the MesoSphere Repo '''
def install_mesosphere_repo (mode="install"):
    def install ():
        mesosphere_repo='http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm'
        sudo ('if [ -z "$( rpm -qa | grep mesosphere-el-repo )" ]; then yum install --assumeyes --quiet %s; fi' % mesosphere_repo)
    def clean ():
        yum_install (mode, "mesosphere-el-repo", "mesosphere-el-repo")
    return execute_op (mode, install, clean)

''' Determine if a package is installed '''
def yum_installed (package):
    return 'if [ "$(rpm -qa | grep -c %s)" -gt 0  ]; then true; fi' % package

''' Get a yum command ''' 
def get_yum_command (sudo=True, install=True):
    command = Template('if [ "$$(rpm -qa | grep -c %s)" $compareop 0  ]; then $yum $command --assumeyes --quiet %s; fi')
    yum = "sudo yum" if sudo else "yum"
    if install:
        command = command.substitute (yum=yum, compareop='==', command='install')
    else:
        command = command.substitute (yum=yum, compareop='-gt', command='remove')
    return command

''' Invoke yum '''
def yum_install (mode, query, package):
    def install ():
        sudo (get_yum_command () % (query, package))
    def clean ():
        sudo (get_yum_command(sudo=False, install=False) % (query, package))
    return execute_op (mode, install, clean)

# SystemD

''' Configure a systemd service ''' 
def configure_service (mode, service):
    def install ():
        sudo ('systemctl enable %s' % service)
        sudo ('systemctl stop %s' % service)
        sudo ('systemctl start %s' % service)
        sudo ('systemctl status %s' % service)
    def clean ():
        sudo ('systemctl stop %s' % service)
        sudo ('systemctl disable %s' % service)
    return execute_op (mode, install, clean)

##################################################################
##
## Targets
##
##################################################################

''' configure the web server '''
def web (mode="install"):
    def install ():
        ''' Install nginx '''
        local (get_yum_command (sudo=True) % ("nginx", "nginx"))

        ''' Install basic apps '''
        for app in base_apps:
            local (get_yum_command (sudo=True) % (app, base_apps[app]))

        ''' Configure proxy '''
        local ('sudo cp %s/nginx/nginx.conf /etc/nginx' % conf)
        local ('sudo cp -r %s/nginx/conf.d /etc/nginx' % conf)
        local ('sudo service nginx stop')
        local ('sudo service nginx start')
        local ('sudo service nginx status')

    def clean ():
        local (get_yum_command(sudo=True, install=False) % ("nginx", "nginx"))
        local (get_yum_command(sudo=True, install=False) % ("nginx-filesystem", "nginx-filesystem"))
        local ('sudo rm -rf /etc/nginx')
        for app in base_apps:
            local (get_yum_command (sudo=True, install=False) % (app, base_apps[app]))
    return execute_op (mode, install, clean)

''' Configure head nodes '''        
@hosts(head_nodes)
def heads (mode="install"):
    install_mesosphere_repo (mode)
    package_map = {
        'haproxy-'             : 'haproxy',
        'emacs-'               : 'emacs',
        'mesos-'               : 'mesos',
        'marathon-'            : 'marathon',
        'chronos-'             : 'chronos',
        'mesosphere-zookeeper' : 'mesosphere-zookeeper' }
    for key in package_map:
        yum_install (mode, key, package_map[key])
    sudo ('rm -rf /etc/mesos-master/quorum.rpm*')

    def install ():
        sudo ('echo 2 > /etc/mesos-master/quorum')
        sudo ('echo 1 > /var/lib/zookeeper/myid')
        addr = local ("ping -c 1 %s | awk 'NR==1{gsub(/\(|\)/,\"\",$3);print $3}'" % zookeeper_nodes, capture=True)
        zoo_cfg = """
server1.%s:2888:3888        
dataDir=/var/log/zookeeper
clientPort=2181
""" % addr
        sudo ('echo \"%s\" > /etc/zookeeper/conf/zoo.cfg' % zoo_cfg)
        conf_base_node (mode)
    def clean ():
        sudo ('rm -rf /etc/mesos-master/quorum')
        sudo ('rm -rf /var/lib/zookeeper/myid')
        sudo ('rm -rf /etc/zookeeper/conf/zoo.cfg')

    firewall (mode)
    services (mode)

    return execute_op (mode, install, clean)

''' Configure head node systemD services '''
def services (mode="install"):
    def install ():
        sudo ('cp %s/mesos/mesos-master.service /usr/lib/systemd/system/' % conf)
        sudo ('cp %s/marathon/marathon.service  /usr/lib/systemd/system/' % conf)
        sudo ('cp %s/chronos/chronos.service    /usr/lib/systemd/system/' % conf)
    def clean ():
        sudo ('rm /usr/lib/systemd/system/mesos-master.service')
        sudo ('rm /usr/lib/systemd/system/marathon.service')
        sudo ('rm /usr/lib/systemd/system/chronos/chronos.service')
    configure_service (mode, 'mesos-master')
    configure_service (mode, 'marathon')
    configure_service (mode, 'chronos')
    return execute_op (mode, install, clean)

''' Configure orchestration server '''
def orchestration ():
    with cd (opt):
        sudo ('mkdir -p /opt/app')
        sudo ('chown %s /opt/app' % env.user)
        run ('git clone https://github.com/stevencox/orchestration.git')
    with cd (orchestration):
        run ('cp %s/orchestration/local_config.json %s/etc' % (conf, orchestration))
        sudo ('-E ./bin/orch.sh run dev -c ./etc/local_config.json')

''' Configure head node firewall ''' 
def firewall (mode="install"):
    def install ():
        sudo ('if [ ! -f /etc/sysconfig/iptables.orig ]; then cp /etc/sysconfig/iptables /etc/sysconfig/iptables.orig; fi')
        sudo ('cp %s/iptables.headnode /etc/sysconfig/iptables' % conf)
        sudo ('service iptables restart')
        sudo ('service iptables status')
    def clean ():
        sudo ('cp /etc/sysconfig/iptables.orig /etc/sysconfig/iptables')
        sudo ('service iptables stop')
        sudo ('service iptables status')

''' Applies to every worker node. Configure worker and firewall. '''
@hosts(worker_nodes)
def workers (mode="install"):
    install_mesosphere_repo (mode)
    conf_base_node (mode)
    def install ():
        sudo ("systemctl enable mesos-slave")
        sudo ("service mesos-slave restart")
        sudo ("service mesos-slave status")
        sudo ('service iptables stop')
    def clean ():
        sudo ('service iptables start')
        sudo ('service iptables status') 
        sudo ("systemctl disable mesos-slave")
        sudo ("service mesos-slave stop")
    yum_install (mode, "mesos-", "mesos")
    return execute_op (mode, install, clean)

''' Applies to every machine '''
@hosts(cluster_nodes)
def conf_base_node (mode="install"):
    def install ():
        # Deploy standard bashrc to all worker nodes (controlling user environment).
        sudo ('cp %s/evryscope.bashrc /home/evryscope/.bashrc' % conf)
        # Deploy zookeeper configuration (identifying quorum hosts) to all nodes.
        addr = local ("ping -c 1 %s | awk 'NR==1{gsub(/\(|\)/,\"\",$3);print $3}'" % zookeeper_nodes, capture=True)
        print "zookeeper hosts: %s" % addr
        text = "%s:2181" % addr
        sudo ('echo zk://%s/mesos > /etc/mesos/zk' % text)
        # Deploy base apps everywhere.
        for app in base_apps:
            yum_install (mode, app, base_apps[app])
    def clean ():
        sudo ('rm -rf /etc/mesos/zk')
        for app in base_apps:
            yum_install (mode, app, base_apps[app])
    return execute_op (mode, install, clean)

''' Configure zookeeper cluster '''
@hosts(zookeeper_nodes)
def zoo (mode="install"):
    configure_service (mode, 'zookeeper')

''' Configure general tools underlying the cluster '''
@hosts(zookeeper_nodes)
def devstack (mode="install"):
    run('hostname -f')
    run('mkdir -p %s' % dist)
    run('mkdir -p %s' % stack)
    run('mkdir -p %s' % app)
    with cd (dist):
        run ('wget --timestamping --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jdk-8u60-linux-x64.tar.gz" ')

    with cd (stack):
        deploy_tar     (mode, 'jdk')
        deploy_uri_tar (mode, 'maven')

        deploy_uri_tar (mode, 'scala')
        deploy_uri_tar (mode, 'spark')

        deploy_uri_tar (mode, 'node')
        deploy_uri_tar (mode, 'mongodb')

        deploy_uri_tar (mode, 'hadoop')
        deploy_uri_tar (mode, 'tachyon')

''' Configure astroinformatics stack '''
@hosts(cluster_nodes)
def astro (mode="install"):
    deploy_uri_rpm (mode, 'swarp')
