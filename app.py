from flask import Flask, url_for, jsonify, request
from flask import render_template
import psycopg2
import psycopg2.extras
import pprint
import logging

logger = logging.getLogger (__name__)

app = Flask(__name__)

dbname="evryscope"
dbuser="evryscope"
dbhost="locahost"
dbpass="evryscope"

conn = None
try:
    conn = psycopg2.connect (dbname=dbname,
                             user=dbuser,
                             password=dbpass)
except:
    print "I am unable to connect to the database"
print "connected"


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

if __name__ == '__main__':
    logging.basicConfig(level=logging.DEBUG)
    app.run(debug=True)


'''
(evry)[scox@mac~/dev/evry]$ psql --username=evryscope
psql (9.3.4, server 9.4.0)
WARNING: psql major version 9.3, server major version 9.4.
         Some psql features might not work.
Type "help" for help.

evryscope=> create table light_curves ( id integer, curve int[][] ); 
CREATE TABLE
evryscope=> create table images ( id integer, path varchar(255) ); 
CREATE TABLE


evryscope=> insert into light_curves values (0, [ [0, 1, 2] ]);
ERROR:  syntax error at or near "["
LINE 1: insert into light_curves values (0, [ [0, 1, 2] ]);
                                            ^
evryscope=> insert into light_curves values (0, '{ { 0, 1, 2 } }');
INSERT 0 1
evryscope=> select * from light_curves;
 id |   curve   
----+-----------
  0 | {{0,1,2}}
(1 row)



GRANT SELECT ON ALL TABLES IN SCHEMA public TO evryscope;





FITS to SVG
http://aplpy.readthedocs.org/en/stable/howto_noninteractive.html

Polymaps SVG Tiler
http://polymaps.org/

http://www.dimin.net/software/panojs/#Demos

'''
