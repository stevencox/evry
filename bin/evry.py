import os
from fabric.api import execute
from fabric.api import hosts
from fabric.api import parallel
from fabric.api import run
from fabric.api import settings
from fabric.api import sudo
from fabric.api import task
import stars_util as su

env = su.get_env ()

@task
@parallel
@hosts(env.work_nodes)
def killevry (mode="install"):
    sudo ('pgrep -a ssh')

@task
@hosts(env.db_nodes)
def db (mode="install"):
    def install ():
        sudo ('cp %s/db/iptables /etc/sysconfig/iptables' % env.conf)
        sudo ('service iptables restart')

        sudo ('rm -rf /usr/lib/pgsql')
        su.yum_install (mode, 'postgresql-', 'postgresql')
        su.yum_install (mode, 'postgresql-server', 'postgresql-server')
        su.yum_install (mode, 'postgresql-devel', 'postgresql-devel')

        run ('wget --quiet --timestamping http://ftp.eenet.ee/pub/postgresql/projects/pgFoundry/pgsphere/pgsphere/1.1.1/pgsphere-1.1.1.tar.gz')
        run ('tar xzf pgsphere-1.1.1.tar.gz')
        with cd ('pgsphere-1.1.1'):
            run ('make USE_PGXS=1 PG_CONFIG=/usr/bin/pg_config')
            sudo ('make USE_PGXS=1 PG_CONFIG=/usr/bin/pg_config install')

        sudo ('rm -rf /var/lib/pgsql/data/*')
        sudo ('postgresql-setup initdb')
        sudo ('cp %s/db/postgresql.conf /var/lib/pgsql/data/postgresql.conf' % env.conf)
        sudo ('cp %s/db/pg_hba.conf   /var/lib/pgsql/data/pg_hba.conf' % env.conf)

        sudo ('pkill -f postgres')
        sudo ('su - postgres -c "pg_resetxlog -f /var/lib/pgsql/data" ')
        su.configure_service (mode, 'postgresql')

        sudo ('su - postgres -c "psql < %s/evry/db/evryscope.init.sql"' % su.app)
        sudo ('su - postgres -c "psql %s < %s/evry/db/evryscope.schema"' % (env.user, su.app))
        sudo ("su - postgres -c \"psql %s -c '\\d light_curves' \" " % env.user)
        sudo ("su - postgres -c \"psql %s -c '\\d images' \" " % env.user)

    def clean ():
        su.configure_service (mode, 'postgresql')
        su.yum_install (mode, 'postgresql-', 'postgresql')
        su.yum_install (mode, 'postgresql-server', 'postgresql-server')
        su.yum_install (mode, 'postgresql-devel', 'postgresql-devel')
        sudo ('rm -rf /var/lib/pgsql')
    return su.execute_op (mode, install, clean)

''' Configure astroinformatics stack '''
@task
@parallel
@hosts(env.work_nodes)
def astro (mode="install"):
    su.add_dist ('swarp', 'http://www.astromatic.net/download/swarp/swarp-2.38.0-1.x86_64.rpm')
    su.add_dist ('sextractor', 'http://www.astromatic.net/download/sextractor/sextractor-2.19.5-1.x86_64.rpm')
    su.deploy_uri_rpm (mode, 'swarp')
    su.deploy_uri_rpm (mode, 'sextractor')

@task(alias='confmesos')
@parallel
@hosts(env.head_nodes[0])
def configure_mesos_services (mode="install"):
    run ('%s/evry/bin/backup restore' % su.app)

@task
def all (mode="install"):
    execute (db,    mode=mode,  hosts=env.work_nodes)
    execute (astro, mode=mode,  hosts=env.work_nodes)

@task
@parallel
@hosts(env.work_nodes)
def status ():
    with settings(warn_only=True):
        run ('ps -ef | grep -v grep | grep python | grep app.py | grep venv')
 
