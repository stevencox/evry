import argparse
import glob
import logging
import pprint
import psycopg2
import psycopg2.extras
import traceback
import yaml

from string import Template
from flask import Flask, url_for, jsonify, request, make_response, g
from flask import render_template

logger = logging.getLogger (__name__)
logging.basicConfig(level=logging.DEBUG)

app = Flask(__name__)
config = None
conn = None
image_location = None

def load_config (config):
    result = None
    with open(config, 'r') as stream:
        result = yaml.load (stream)
    return result

def connect ():
    result = None
    if not result:
        try:
            dbhost = config['dbhost']
            dbname = config['dbname']
            dbuser = config['dbuser']
            dbpassword = config['dbpass']
            result = psycopg2.connect (host=dbhost,
                                       dbname=dbname,
                                       user=dbuser,
                                       password=dbpassword)
            logger.info ("Connection object: {0}".format (result))
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

    parser = argparse.ArgumentParser(description='Evryscope web app')
    parser.add_argument('--config', action="store", dest="config", default='conf/evry-dev.yaml')
    args = parser.parse_args ()
    
    config = load_config (args.config)

    image_location = config['image_location']

    logging.basicConfig(level=logging.DEBUG)

    logger.info ("Using configuration: {0}".format (args.config))

    conn = connect ()
    app.run(
        host="0.0.0.0",
        port=int("5000"),
        debug=True
    )
