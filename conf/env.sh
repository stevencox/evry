# Stars Environment Variables

STARS_HOME=/projects/stars
STARS_VENV=$STARS_HOME/venv
STARS_APP=$STARS_HOME/app
STARS_STACK=$STARS_HOME/stack
STARS_DATA=$STARS_HOME/var

if [[ ! -f $STARS_VENV/bin/activate ]]; then
    echo creating stars virtual env
    cd $STARS_HOME
    virtualenv venv
fi
source $STARS_VENV/bin/activate
pip install --quiet fabric flask requests

SPARK_HOME=$STARS_STACK/spark/current
export PATH=$SPARK_HOME/bin:$PATH

MAVEN_HOME=$STARS_STACK/maven/current
export PATH=$MAVEN_HOME/bin:$PATH

JAVA_HOME=$STARS_STACK/jdk/current
export PATH=$JAVA_HOME/bin:$PATH

NODE_HOME=$STARS_STACK/node/current
export PATH=$NODE_HOME/bin:$PATH

MONGO_HOME=$STARS_STACK/mongodb/current
export PATH=$MONGO_HOME/bin:$PATH

cd $STARS_APP/evry

