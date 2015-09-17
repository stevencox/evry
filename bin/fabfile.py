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

# monit
# http://www.itzgeek.com/how-tos/linux/centos-how-tos/monitor-and-manage-services-with-monit-on-centos-7-rhel-7.html

# the user to use for the remote commands

env.user = 'scox'
env.user = 'evryscope'

root  = "/projects/stars"
stack = "%s/stack" % root
app   = "%s/app"   % root
dist  = "%s/dist"  % root
conf  = "%s/conf"  % root

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

base_apps = {
    'python-virtualenv' : 'python-virtualenv',
    'monit-'            : 'monit',
    'git-'               : 'git'
}

# Servers where the commands are executed
head_nodes = (
    'stars-c0.edc.renci.org',
    'stars-c1.edc.renci.org'
)
worker_nodes = (
    'stars-c2.edc.renci.org',
    'stars-c3.edc.renci.org',
    'stars-c4.edc.renci.org',
    'stars-c5.edc.renci.org',
    'stars-c6.edc.renci.org',
    'stars-c7.edc.renci.org'
)

zookeeper_nodes=( 'stars-c0.edc.renci.org' )

cluster_nodes = tuple(list(head_nodes) + list(worker_nodes))

##################################################################
##
## Utilities
##
##################################################################

def stackpath (name):
    return "%s/%s" % (stack, name)
def execute_op (mode, install, clean):
    installed = True
    if mode == "install":
        install ()
    elif mode == "clean":
        clean ()
        installed = False
    return installed

# Tar

def untar_and_link (name, file_name):
    run ('tar xzf %s/%s' % (dist, file_name))
    run ('ln -s *%s* current' % name)
    run ('ls -lisa')

def deploy_uri_tar (mode, name):
    path = "%s/%s" % (stack, name)
    def install ():
        uri = dist_map [name]
        run ('rm -rf %s' % path)
        run ('mkdir -p %s' % path)
        with cd (path):
            with cd (dist):
                run ('wget --timestamping --quiet %s' % uri)
            untar_and_link (name, os.path.basename (uri))
    def clean ():
        run ('rm -rf %s' % path)
    return execute_op (mode, install, clean)

def deploy_uri_rpm (mode, name):
    path = "%s/%s" % (stack, name)
    def install ():
        uri = dist_map [name]
        run ('rm -rf %s' % path)
        run ('mkdir -p %s' % path)
        with cd (path):
            with cd (dist):
                yum_install (mode, name, dist_map[name])
    def clean ():
        yum_install (mode, name, name)
    return execute_op (mode, install, clean)

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

def install_mesosphere_repo ():
    mesosphere_repo='http://repos.mesosphere.com/el/7/noarch/RPMS/mesosphere-el-repo-7-1.noarch.rpm'
    sudo ('if [ -z "$( rpm -qa | grep mesosphere-el-repo )" ]; then yum install --assumeyes --quiet %s; fi' % mesosphere_repo)

def yum_installed (package):
    return 'if [ "$(rpm -qa | grep -c %s)" -gt 0  ]; then true; fi' % package

def get_yum_command (sudo=True, install=True):
    command = Template('if [ "$$(rpm -qa | grep -c %s)" $compareop 0  ]; then $yum $command --assumeyes --quiet %s; fi')
    yum = "sudo yum" if sudo else "yum"
    if install:
        command = command.substitute (yum=yum, compareop='==', command='install')
    else:
        command = command.substitute (yum=yum, compareop='-gt', command='remove')

    return command

def yum_install (mode, query, package):
    def install ():
        sudo (get_yum_command () % (query, package))
    def clean ():
        sudo (get_yum_command(sudo=False, install=False) % (query, package))
    return execute_op (mode, install, clean)

# SystemD

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

def web (mode="install"):
    def install ():
        local (get_yum_command (sudo=True) % ("nginx", "nginx"))
        local ('sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.orig')
        local ('sudo cp -r /etc/nginx/conf.d /etc/nginx/conf.d.orig')
        for app in base_apps:
            local (get_yum_command (sudo=True) % (app, base_apps[app]))
    def clean ():
        local (get_yum_command(sudo=True, install=False) % ("nginx", "nginx"))
        local (get_yum_command(sudo=True, install=False) % ("nginx-filesystem", "nginx-filesystem"))
        local ('sudo rm -rf /etc/nginx')
        for app in base_apps:
            local (get_yum_command (sudo=True, install=False) % (app, base_apps[app]))
    return execute_op (mode, install, clean)

def proxy (mode="install"):
    def install ():        
        local ('sudo cp -r %s/nginx/nginx.conf /etc/nginx' % conf)
        local ('sudo cp -r %s/nginx/conf.d /etc/nginx' % conf)
        local ('sudo service nginx stop')
        local ('sudo service nginx start')
        local ('sudo service nginx status')
    def clean ():
        local ('sudo cp /etc/nginx/nginx.conf.orig /etc/nginx/nginx.conf')
        local ('sudo cp -r /etc/nginx/nginx.conf.orig /etc/nginx/conf.d')
    return execute_op (mode, install, clean)
        
@hosts(head_nodes)
def heads (mode="install"):
    install_mesosphere_repo ()
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

    configure_service (mode, 'mesos-master')
    configure_service (mode, 'marathon')
    configure_service (mode, 'chronos')

    return execute_op (mode, install, clean)

@hosts(head_nodes)
def head_iptables (mode="install"):
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
    def install ():
        install_mesosphere_repo ()
        yum_install (mode, "mesos-", "mesos")
        conf_base_node (mode)
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
        conf_base_node (mode)
    return execute_op (mode, install, clean)

''' Applies to every machine '''
@hosts(cluster_nodes)
def conf_base_node (mode="install"):
    def install ():
        addr = local ("ping -c 1 %s | awk 'NR==1{gsub(/\(|\)/,\"\",$3);print $3}'" % zookeeper_nodes, capture=True)
        print "zookeeper hosts: %s" % addr
        text = "%s:2181" % addr
        sudo ('echo zk://%s/mesos > /etc/mesos/zk' % text)
        for app in base_apps:
            yum_install (mode, app, base_apps[app])
    def clean ():
        sudo ('rm -rf /etc/mesos/zk')
        for app in base_apps:
            yum_install (mode, app, base_apps[app])
    return execute_op (mode, install, clean)

''' Configure zookeeper cluster '''        
@hosts(zookeeper_nodes)
def zookeeper (mode="install"):
    configure_service (mode, 'zookeeper')

''' Configure general tools underlying the cluster '''
@hosts(zookeeper_nodes)
def devstack (mode="install"):
    run('hostname -f')
    run('mkdir -p %s' % dist)
    run('mkdir -p %s' % stack)
    run('mkdir -p %s' % app)
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
