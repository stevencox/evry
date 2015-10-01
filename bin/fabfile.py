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
import StringIO

from string import Template

from fabric.api import cd
from fabric.api import env
from fabric.api import execute
from fabric.api import hosts
from fabric.api import local
from fabric.api import parallel
from fabric.api import put
from fabric.api import settings
from fabric.api import run
from fabric.api import sudo
from fabric.contrib.files import exists

# User identity for remote commands
env.user = 'evryscope'

''' Concatenate lists of tuples '''
def concat (T):
    A = []
    for element in T:
        if isinstance(element, basestring):
            A.append (element)
        elif isinstance (element, tuple):
            for i in element:
                A.append (i)
    return tuple (A)

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

# Database nodes
db_nodes = (
    'stars-db.edc.renci.org'
)

# Zookeeper nodes
zookeeper_nodes=( 'stars-c0.edc.renci.org' )

# Head nodes plus workers
cluster_nodes = concat ([ head_nodes, worker_nodes, db_nodes ])

# Paths
root  = "/projects/stars"
stack = "%s/stack" % root
app   = "%s/app"   % root
dist  = "%s/dist"  % root
conf  = "%s/app/evry/conf" % root

opt   = "/opt/app"
orchestration_path = "%s/orchestration" % opt

# Third party libraries to install
dist_map = {
    'spark'      : 'http://apache.arvixe.com/spark/spark-1.5.0/spark-1.5.0-bin-hadoop2.6.tgz',
    'scala'      : 'http://www.scala-lang.org/files/archive/scala-2.10.4.tgz',    
    'jdk'        : 'jdk-8u60-linux-x64.tar.gz',
    'maven'      : 'http://apache.mirrors.lucidnetworks.net/maven/maven-3/3.3.3/binaries/apache-maven-3.3.3-bin.tar.gz',
    'mongodb'    : 'https://fastdl.mongodb.org/linux/mongodb-linux-x86_64-rhel70-3.0.6.tgz',
    'node'       : 'https://nodejs.org/dist/v0.12.7/node-v0.12.7-linux-x64.tar.gz',
    'hadoop'     : 'http://apache.arvixe.com/hadoop/common/hadoop-2.6.0/hadoop-2.6.0.tar.gz',
    'tachyon'    : 'http://tachyon-project.org/downloads/files/0.7.1/tachyon-0.7.1-bin.tar.gz',
    'swarp'      : 'http://www.astromatic.net/download/swarp/swarp-2.38.0-1.x86_64.rpm',
    'sextractor' : 'http://www.astromatic.net/download/sextractor/sextractor-2.19.5-1.x86_64.rpm'
}

# Apps we want on all machines
base_apps = {
    'python-virtualenv' : 'python-virtualenv',
    'git-'              : 'git',
    'emacs-24'          : 'emacs'
}

# Git repositories
evry_app_git_uri = "https://github.com/stevencox/evry.git"
orchestration_app_git_uri = "https://github.com/stevencox/orchestration.git"

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

# File permissions

''' Make a directory owned by the env user '''
def mkdir_mine (d):
    sudo ('mkdir -p %s' % d)
    sudo ('chown %s %s' % (env.user, d))

''' Make a file owned by the env user '''
def mkfile_mine (f):
    sudo ('touch %s' % f)
    sudo ('chown %s %s' % (env.user, f))
    
# Tar

''' Untar a file and create a symbolic link called current to the extracted folder '''
def untar_and_link (name, file_name):
    run ('if [[ ! -h current ]]; then tar xzf %s/%s; fi' % (dist, file_name))
    run ('if [[ ! -h current ]]; then ln -s *%s* current; fi' % name)
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
def mesosphere_repo (mode="install"):
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
        sudo (get_yum_command(install=False) % (query, package))
    return execute_op (mode, install, clean)

def yum_install_all (mode, packages):
    packages = packages.split (' ')
    for p in packages:
        yum_install (mode, p, p)

# SystemD

''' Configure a systemd service ''' 
def configure_service (mode, service):
    def install ():
        sudo ('systemctl enable %s' % service)
        sudo ('systemctl restart %s' % service)
        sudo ('systemctl status %s' % service)
    def clean ():
        with settings(warn_only=True):
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

        ''' Configure iptables '''
        sudo ('if [ ! -f /etc/sysconfig/iptables.orig ]; then cp /etc/sysconfig/iptables /etc/sysconfig/iptables.orig; fi')
        sudo ('cp %s/iptables.web /etc/sysconfig/iptables' % conf)
        sudo ('service iptables restart')
        sudo ('service iptables status')

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
def head (mode="install"):
    mesosphere_repo (mode)
    base (mode)
    zoo (mode)
    def install ():
        addr = local ("ping -c 1 %s | awk 'NR==1{gsub(/\(|\)/,\"\",$3);print $3}'" % zookeeper_nodes, capture=True)
        zoo_cfg = """
server1.%s:2888:3888        
dataDir=/var/log/zookeeper
clientPort=2181
""" % addr
        sudo ('echo \"%s\" > /etc/zookeeper/conf/zoo.cfg' % zoo_cfg)
        sudo ('sh -c "echo IP=$(hostname -I) > /etc/network-environment" ')
        firewall (mode)
        mesos (mode)
        marathon (mode)
        chronos (mode)
        orchestration (mode)
    def clean ():
        orchestration (mode)
        chronos (mode)
        marathon (mode)
        mesos (mode)
        firewall (mode)
        sudo ('rm -rf /var/lib/zookeeper')
        sudo ('rm -rf /etc/zookeeper')
    return execute_op (mode, install, clean)

@parallel
@hosts(head_nodes[0])
def configure_mesos_services (mode="install"):
    run ('%s/evry/bin/backup restore' % app)

@parallel
@hosts(head_nodes)
def marathon (mode="install"):
    def install ():
        yum_install (mode, "marathon-", "marathon")
        run ('gem install marathon_client')
    def clean ():
        run ('gem uninstall --quiet --executables marathon_client')
        yum_install (mode, "marathon-", "marathon")
    return execute_op (mode, install, clean)
        
@parallel
@hosts(head_nodes)
def chronos (mode="install"):
    def install ():
        yum_install (mode, "chronos-", "chronos")
        configure_service (mode, 'chronos')
    def clean ():
        configure_service (mode, 'chronos')
        yum_install (mode, "chronos-", "chronos")
    return execute_op (mode, install, clean)

def generate_config (template, context, output=None, use_sudo=False):
    result = None
    with open (template) as stream:
        template_obj = Template (stream.read ())
        result = template_obj.safe_substitute (context)
    if output:
        put (StringIO.StringIO (result), output, use_sudo=use_sudo, temp_dir='/tmp')
    return result

@hosts(head_nodes)
def mesos (mode="install"):
    mesos_21 (mode)

@parallel
@hosts(head_nodes)
def mesos_24(mode="install"):
    def install ():
        yum_install (mode, "mesos-", "mesos")
        sudo ('rm -rf /etc/mesos-master/quorum.rpm*')
        sudo ('echo 2 > /etc/mesos-master/quorum')
        sudo ('chown -R %s /var/log/mesos' % env.user)
        sudo ('chown -R %s /var/lib/mesos' % env.user)
        sudo ('cp %s/mesos/mesos-master.service /usr/lib/systemd/system/' % conf)
        configure_service (mode, 'mesos-master')
    def clean ():
        configure_service (mode, 'mesos-master')
        sudo ('rm -rf /etc/mesos-master/quorum')
        sudo ('rm -f /usr/lib/systemd/system/mesos-master.service')
        yum_install (mode, "mesos-", "mesos")
    return execute_op (mode, install, clean)

def mesos_21_install (mode):
    def install ():
        sudo ('rm -rf /usr/lib/systemd/system/mesos-master.service')
        with settings(warn_only=True):
            libs = ' '.join ([ 'apache-maven python-devel java-1.7.0-openjdk-devel zlib-devel libcurl-devel',
                               'openssl-devel cyrus-sasl-devel cyrus-sasl-md5 apr-devel subversion-devel apr-util-devel' ])
            yum_install_all (mode, libs) 
        with cd (opt):
            sudo ('rm -rf mesos')
            sudo ('mkdir -p mesos')
            sudo ('chown %s mesos' % env.user)
            run ('mkdir -p mesos')
            with cd ('mesos'):
                run ('tar xzf %s/mesos-renci-0.21.0.tar.gz' % dist)
                with cd ('mesos-0.21.0'):
                    sudo ('make install 2>&1 > mesos-install.log')
        #sudo ('rm -rf %s/mesos/mesos-0.21.0/src/' % opt)
    def clean ():
        sudo ('rm -rf %/mesos' % opt)
    return execute_op (mode, install, clean)

@hosts(head_nodes)
def mesos_21(mode="install"):
    def install ():
        mesos_21_install (mode)
        ip_addr = run ('hostname -I')
        zk_string = run ('cat /etc/mesos/zk')
        generate_config (
            template='%s/mesos/mesos-master.service.custom' % conf,
            context={
                'EXE'      : '%s/mesos/mesos-0.21.0/bin/mesos-master.sh' % opt,
                'IP'       : ip_addr,
                'ZK'       : zk_string,
                'LOGLEVEL' : 'WARNING',
                'LOGDIR'   : '/var/log/mesos',
                'QUORUM'   : 2
            },
            output='/usr/lib/systemd/system/mesos-master.service',
            use_sudo=True)
        sudo ('rm -rf /etc/mesos-master/quorum.rpm*')
        sudo ('echo 2 > /etc/mesos-master/quorum')
        sudo ('chown -R %s /var/log/mesos' % env.user)
        sudo ('chown -R %s /var/lib/mesos' % env.user)
        configure_service (mode, 'mesos-master')
    def clean ():
        configure_service (mode, 'mesos-master')
        sudo ('rm -rf /etc/mesos-master/quorum')
        sudo ('rm -f /usr/lib/systemd/system/mesos-master.service')
        yum_install (mode, "mesos-", "mesos")
    return execute_op (mode, install, clean)

@parallel
@hosts(head_nodes)
def head_restart ():
    services = [ 'orchestration', 'chronos', 'marathon', 'mesos-master', 'zookeeper' ]
    map (lambda s : sudo ('service %s stop' % s), services)
    map (lambda s : sudo ('service %s start' % s), reversed (services))

''' Configure head node systemD services '''
@parallel
@hosts(head_nodes)
def services (mode="install"):
    def install ():
        sudo ('cp %s/marathon/marathon.service  /usr/lib/systemd/system/' % conf)
    def clean ():
        sudo ('rm -f /usr/lib/systemd/system/marathon.service')
        sudo ('rm -f /usr/lib/systemd/system/chronos/chronos.service')
        sudo ('rm -f /usr/lib/systemd/system/chronos/orchestration.service')
    configure_service (mode, 'mesos-master')
    configure_service (mode, 'marathon')
    configure_service (mode, 'chronos')
    return execute_op (mode, install, clean)

''' Configure orchestration server '''
@parallel
@hosts(head_nodes)
def orchestration (mode="install"):
    def install ():
        yum_install (mode, 'haproxy-', 'haproxy')
        mkdir_mine ('/opt/app')
        mkdir_mine ('/var/log/orchestration')
        mkfile_mine ('/etc/haproxy/haproxy.auto.cfg')
        with cd (opt):
            sudo ('rm -rf orchestration')
            run ('git clone --quiet %s' % orchestration_app_git_uri)
        with cd (orchestration_path):
            run ('cp %s/orchestration/local_config.json %s/etc' % (conf, orchestration_path))
            sudo ('cp %s/orchestration/orchestration.service /usr/lib/systemd/system' % conf)
        sudo ('service haproxy stop')
        configure_service (mode, 'orchestration')
    def clean ():
        configure_service (mode, 'orchestration')
        configure_service (mode, 'haproxy')
        yum_install (mode, 'haproxy-', 'haproxy')
        sudo ('rm -rf /var/log/orchestration')
        sudo ('rm -rf /opt/app/orchestration')
    return execute_op (mode, install, clean)

''' Configure head node firewall ''' 
@parallel
@hosts(head_nodes)
def firewall (mode="install"):
    def install ():
        sudo ('if [ ! -f /etc/sysconfig/iptables.orig ]; then cp /etc/sysconfig/iptables /etc/sysconfig/iptables.orig; fi')
        sudo ('cp %s/iptables.headnode /etc/sysconfig/iptables' % conf)
#        sudo ('service iptables restart')
        sudo ('service iptables stop') # spark assigns random ports for driver/worker communication.
#        sudo ('service iptables status')
    def clean ():
        sudo ('cp /etc/sysconfig/iptables.orig /etc/sysconfig/iptables')
        sudo ('service iptables stop')
        sudo ('service iptables status')
    return execute_op (mode, install, clean)

@parallel
@hosts(worker_nodes)
def work (mode="install"):
    work_21 (mode)

''' Applies to every worker node. Configure worker and firewall. '''
@parallel
@hosts(worker_nodes)
def work_24 (mode="install"):
    mesosphere_repo (mode)
    # Needed by evry app
    yum_install (mode, 'postgresql-devel', 'postgresql-devel')
    base (mode)
    def install ():
        yum_install (mode, "mesos-", "mesos")
        sudo ("systemctl enable mesos-slave")
        sudo ("service mesos-slave restart")
        sudo ("service mesos-slave status")
        sudo ('service iptables stop')
        # Support application installation
        sudo ('mkdir -p %s' % opt)
        sudo ('chown %s %s' % (env.user, opt))
    def clean ():
        with settings(warn_only=True):
            sudo ('service iptables start')
            sudo ('service iptables status') 
            sudo ("systemctl disable mesos-slave")
            sudo ("service mesos-slave stop")
            yum_install (mode, "mesos-", "mesos")
    return execute_op (mode, install, clean)

@parallel
@hosts(worker_nodes)
def work_21 (mode="install"):
    sudo ('rm -rf /opt/app/mesos/mesos-0.21.0/src/')
    sudo ('yum clean all')
    mesos_21_install (mode)
    mesosphere_repo (mode)
    # Needed by evry app
    yum_install (mode, 'postgresql-devel', 'postgresql-devel')
    base (mode)
    def install ():
        zk_string = run ('cat /etc/mesos/zk')
        generate_config (
            template='%s/mesos/mesos-slave.service.custom' % conf,
            context={
                'EXE'      : '%s/mesos/mesos-0.21.0/bin/mesos-slave.sh' % opt,
                'ZK'       : zk_string,
                'LOGDIR'   : '/var/log/mesos'
            },
            output='/usr/lib/systemd/system/mesos-slave.service',
            use_sudo=True)
        sudo ("systemctl enable mesos-slave")
        sudo ("service mesos-slave restart")
        sudo ("service mesos-slave status")
        sudo ('service iptables stop')
        # Support application installation
        sudo ('mkdir -p %s' % opt)
        sudo ('chown %s %s' % (env.user, opt))
    def clean ():
        with settings(warn_only=True):
            sudo ('service iptables start')
            sudo ('service iptables status') 
            sudo ("systemctl disable mesos-slave")
            sudo ("service mesos-slave stop")
            yum_install (mode, "mesos-", "mesos")
    return execute_op (mode, install, clean)    

''' Applies to every machine '''
@parallel
@hosts(cluster_nodes)
def base (mode="install"):
    def install ():
        # Deploy base apps everywhere.
        for app in base_apps:
            yum_install (mode, app, base_apps[app])
        # Deploy standard bashrc to all worker nodes (controlling user environment).
        sudo ('cp %s/%s.bashrc /home/%s/.bashrc' % (conf, env.user, env.user))
        sudo ('if [ "$(grep -c stars ~/.bashrc)" -eq 0 ]; then echo source %s/env.sh >> ~/.bashrc; fi' % conf)
        # Deploy zookeeper configuration (identifying quorum hosts) to all nodes.
        addr = local ("ping -c 1 %s | awk 'NR==1{gsub(/\(|\)/,\"\",$3);print $3}'" % zookeeper_nodes, capture=True)
        print "zookeeper hosts: %s" % addr
        text = "%s:2181" % addr
        sudo ('sh -c "if [ -d /etc/mesos ]; then echo zk://%s/mesos > /etc/mesos/zk; fi" ' % text)
    def clean ():
        sudo ('rm -rf /etc/mesos/zk')
        for app in base_apps:
            yum_install (mode, app, base_apps[app])
    return execute_op (mode, install, clean)

@parallel
@hosts(worker_nodes)
def killevry (mode="install"):
    sudo ('pgrep -a app.py')
    #sudo ('pkill -f /projects/stars/app/evry/bin/app')

''' Configure zookeeper cluster '''
@parallel
@hosts(zookeeper_nodes)
def zoo (mode="install"):
    def install ():
        yum_install (mode, 'mesosphere-zookeeper', 'mesosphere-zookeeper')
        configure_service (mode, 'zookeeper')
    def clean ():
        configure_service (mode, 'zookeeper')
        yum_install (mode, 'mesosphere-zookeeper', 'mesosphere-zookeeper')
        sudo ('rm -rf /var/lib/zookeeper')
        sudo ('rm -rf /var/log/zookeeper')
    return execute_op (mode, install, clean)
        
''' Configure general tools underlying the cluster '''
@parallel
@hosts(zookeeper_nodes)
def core (mode="install"):
    run('mkdir -p %s' % dist)
    run('mkdir -p %s' % stack)
    run('mkdir -p %s' % app)
    with cd (dist):
        run ("""wget --quiet --timestamping --no-cookies --no-check-certificate \
                     --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
                     "http://download.oracle.com/otn-pub/java/jdk/8u60-b27/jdk-8u60-linux-x64.tar.gz" """)
    with cd (stack):
        spark (mode)
        maven (mode)
        deploy_tar     (mode, 'jdk')
        deploy_uri_tar (mode, 'scala')
        deploy_uri_tar (mode, 'node')
        deploy_uri_tar (mode, 'mongodb')
        deploy_uri_tar (mode, 'hadoop')
        deploy_uri_tar (mode, 'tachyon')

@hosts(zookeeper_nodes)
def maven (mode="install"):
    deploy_uri_tar (mode, 'maven')
    run ('cp %s/maven/settings.xml %s/maven/current/conf' % (conf, stack))

@hosts(zookeeper_nodes)
def spark (mode="install"):
    deploy_uri_tar (mode, 'spark')
    generate_config (
        template='%s/spark/spark-env.sh' % conf,
        context={
            'STARS_CONF' : conf,
            'STARS_DIST' : dist
        },
        output='%s/spark/current/conf/spark-env.sh' % stack)

@hosts(db_nodes)
def db (mode="install"):
    def install ():
        sudo ('cp %s/db/iptables /etc/sysconfig/iptables' % conf)
        sudo ('service iptables restart')

        sudo ('rm -rf /usr/lib/pgsql')
        yum_install (mode, 'postgresql-', 'postgresql')
        yum_install (mode, 'postgresql-server', 'postgresql-server')
        yum_install (mode, 'postgresql-devel', 'postgresql-devel')

        run ('wget --quiet --timestamping http://ftp.eenet.ee/pub/postgresql/projects/pgFoundry/pgsphere/pgsphere/1.1.1/pgsphere-1.1.1.tar.gz')
        run ('tar xzf pgsphere-1.1.1.tar.gz')
        with cd ('pgsphere-1.1.1'):
            run ('make USE_PGXS=1 PG_CONFIG=/usr/bin/pg_config')
            sudo ('make USE_PGXS=1 PG_CONFIG=/usr/bin/pg_config install')

        sudo ('rm -rf /var/lib/pgsql/data/*')
        sudo ('postgresql-setup initdb')
        sudo ('cp %s/db/postgresql.conf /var/lib/pgsql/data/postgresql.conf' % conf)
        sudo ('cp %s/db/pg_hba.conf   /var/lib/pgsql/data/pg_hba.conf' % conf)

        sudo ('pkill -f postgres')
        sudo ('su - postgres -c "pg_resetxlog -f /var/lib/pgsql/data" ')
        configure_service (mode, 'postgresql')

        sudo ('su - postgres -c "psql < %s/evry/db/evryscope.init.sql"' % app)
        sudo ('su - postgres -c "psql %s < %s/evry/db/evryscope.schema"' % (env.user, app))
        sudo ("su - postgres -c \"psql %s -c '\\d light_curves' \" " % env.user)
        sudo ("su - postgres -c \"psql %s -c '\\d images' \" " % env.user)

    def clean ():
        configure_service (mode, 'postgresql')
        yum_install (mode, 'postgresql-', 'postgresql')
        yum_install (mode, 'postgresql-server', 'postgresql-server')
        yum_install (mode, 'postgresql-devel', 'postgresql-devel')
        sudo ('rm -rf /var/lib/pgsql')

    return execute_op (mode, install, clean)

''' Configure astroinformatics stack '''
@parallel
@hosts(cluster_nodes)
def astro (mode="install"):
    deploy_uri_rpm (mode, 'swarp')
    deploy_uri_rpm (mode, 'sextractor')

def all (mode="install"):
    execute (base,  mode=mode,  hosts=cluster_nodes)
    execute (core,  mode=mode,  hosts=worker_nodes)
    execute (head,  mode=mode,  hosts=head_nodes)
    execute (work,  mode=mode,  hosts=worker_nodes)
    execute (db,    mode=mode,  hosts=worker_nodes)
    execute (astro, mode=mode,  hosts=worker_nodes)
