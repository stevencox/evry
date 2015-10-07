# Stars Environment Variables

if [ "$(uname | grep -c Darwin)" -gt 0 ]; then
    export POSTGRESQL_HOME=/Applications/Postgres.app/Contents/Versions/9.4
    export PATH=$POSTGRESQL_HOME/bin:$PATH
fi

VENV=env
if [[ ! -f $VENV/bin/activate ]]; then
    virtualenv env
    source $VENV/bin/activate
fi
pip install --quiet fabric flask requests mock mockito psycopg2 pyyaml argparse
