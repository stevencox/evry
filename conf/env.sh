# Stars Environment Variables

export STARS_HOME=/projects/stars
export STARS_VENV=$STARS_HOME/venv
export STARS_APP=$STARS_HOME/app
export STARS_STACK=$STARS_HOME/stack
export STARS_DATA=$STARS_HOME/var

if [[ ! -f $STARS_VENV/bin/activate ]]; then
    echo creating stars virtual env
    cd $STARS_HOME
    virtualenv venv
fi
source $STARS_VENV/bin/activate
pip install --quiet fabric flask requests mock mockito psycopg2 pyyaml

SPARK_HOME=$STARS_STACK/spark/current
export PATH=$SPARK_HOME/bin:$PATH

MAVEN_HOME=$STARS_STACK/maven/current
export PATH=$MAVEN_HOME/bin:$PATH

export JAVA_HOME=$STARS_STACK/jdk/current
export PATH=$JAVA_HOME/bin:$PATH

NODE_HOME=$STARS_STACK/node/current
export PATH=$NODE_HOME/bin:$PATH

MONGO_HOME=$STARS_STACK/mongodb/current
export PATH=$MONGO_HOME/bin:$PATH

export PATH=$STARS_HOME/app/stars/bin:$PATH

HADOOP_HOME=$STARS_STACK/hadoop/current
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export PATH=$HADOOP_HOME/bin:$PATH

cd $STARS_APP/evry

