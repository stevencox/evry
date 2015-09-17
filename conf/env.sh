# Stars Environment Variables

STARS_HOME=/projects/stars
STARS_VENV=$STARS_HOME/venv
STARS_APP=$STARS_HOME/app

if [ -f $STARS_VENV/bin/activate ]; then
    source $STARS_VENV/bin/activate
else
    cd $STARS_HOME
    virtualenv venv
    source $STARS_VENV/bin/activate
    pip install fabric
fi

cd $STARS_APP/evry



