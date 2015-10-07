from string import Template
from flask import Flask, url_for, jsonify, request, make_response, g
from flask import render_template
import psycopg2
import psycopg2.extras
import pprint
import logging
import glob
import traceback
import yaml

logger = logging.getLogger (__name__)
logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)

def load_config ():
    config = None
    with open("conf/evry-dev.yaml", 'r') as stream:
        config = yaml.load (stream)
    return config

config = load_config ()

dbhost = config['dbhost']
dbname = config['dbname']
dbuser = config['dbuser']
dbpassword = config['dbpass']
image_location = config['image_location']

logger.info ("Database host: {0}, dbname: {1}, user: {2}".format (dbhost, dbname, dbuser))

conn = None

def connect ():
    result = None
    if not result:
        try:
            logger.info ("Connecting to host: {0} db: {1} as user: {2}"
                         .format (dbhost, dbname, dbuser))
            result = psycopg2.connect (host=dbhost,
                                       dbname=dbname,
                                       user=dbuser,
                                       password=dbpassword)
            logger.info ("Connection object: {0}".format (result))
            logger.info ("Connected to host: {0} db: {1} as user: {2}".format (dbhost, dbname, dbuser))
        except Exception, e:
            logger.exception (e)
            traceback.print_exc ()
    return result

def get_image_file_list (image_location):
    return glob.glob('{0}/img*calib'.format (image_location))

@app.before_request
def before_request():
    g.conn = conn if conn else connect ()

@app.route('/')
def app_main ():
    return render_template('main.html') 

@app.route('/query', methods=['POST'])
def login():
    result = {
        "curves" : []
    }
    query = request.form['query']
    if query:
        logger.info ("Executing query: %s", query)
        try:
            cursor = conn.cursor(cursor_factory=psycopg2.extras.DictCursor)
            cursor.execute (query)
            records = cursor.fetchall()
            for row in records:
                result["curves"].append ({
                    "id"    : row [0],
                    "curve" : row [1]
                })
        except psycopg2.Error as e:
            pass
        logger.info ("Returning %s", result)
    return jsonify (**result)

@app.route('/fetchImages', methods=['GET', "POST"])
def fetchImages ():

    prefix = request.args['prefix']
    images = request.args['images']
    images = images.split (',')
    url = request.url_root

    downloadScript = Template ("""
#/bin/bash
set -o
function get_file () {
    fileId=$$1
    fileURI=${url}static/tiles/${prefix}/${prefix}-$${fileId}.png
    echo Downloading $$fileURI
    wget --timestamping $$fileURI
}
$getCommands
exit 0
""")

    getCommands = Template ("""
get_file $file
""")

    commands = []
    for image in images:
        commands.append (getCommands.substitute ({ "file" : image }))
    data = downloadScript.substitute ({
        "url" : url,
        "prefix" : prefix,
        "getCommands" : '\n'.join (commands)
    })
    response = make_response(data)
    response.headers["Content-Disposition"] = "attachment; filename=downloadScript.sh"
    return response

@app.route('/listImages', methods=['POST'])
def listImages():
    logger.info ("Listing images")
    return jsonify ({
        "images" : [ x.split('/')[-1] for x in get_image_file_list (image_location) ]
    })

if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)
    conn = connect ()
    app.run(
        host="0.0.0.0",
        port=int("5000"),
        debug=True
    )
