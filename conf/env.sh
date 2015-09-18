# Stars Environment Variables

STARS_HOME=/projects/stars
STARS_VENV=$STARS_HOME/venv
STARS_APP=$STARS_HOME/app

if [[ ! -f $STARS_VENV/bin/activate ]]; then
    echo creating stars virtual env
    cd $STARS_HOME
    virtualenv venv
fi
source $STARS_VENV/bin/activate
pip install --quiet fabric flask requests

cd $STARS_APP/evry



