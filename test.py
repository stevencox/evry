import json
import os
import evry
import psycopg2
import unittest
import tempfile

from mock import patch
import mockito
from mockito import any
from mockito import mock
from mockito import when

from evry import app

#https://code.google.com/p/mockito-python/wiki/Stubbing#Basics

def get_mock_cursor ():
    mock_cursor = mock ()
    when (mock_cursor).execute (any()).thenReturn (None)
    when (mock_cursor).fetchall ().thenReturn ([
        [ 1, 'x' ],
        [ 2, 'y' ],
    ])
    return mock_cursor

mock_conn = mock ()
when (mock_conn).cursor (cursor_factory=psycopg2.extras.DictCursor).thenReturn (get_mock_cursor ())

def get_mock_connection ():
    return mock_conn

def get_mock_image_file_list (image_location):
    return [ 'mock-file-1', 'mock-file-2' ]

class EvryTestCase(unittest.TestCase):

    def setUp(self):
        evry.app.config['TESTING'] = True
        evry.conn = get_mock_connection ()
        evry.get_image_file_list = get_mock_image_file_list
        self.app = evry.app.test_client()

    def test_root (self):
        rv = self.app.get('/')
        self.assertTrue (rv.data.startswith ('<!doctype html>'))
        self.assertTrue (rv.data.endswith ('</html>'))

    def test_login (self):
        rv = self.app.post('/query', data=dict(
            query='select * from images'
        ))
        obj = json.loads (rv.data)
        self.assertEqual (obj['curves'][0]['curve'], 'x')

    def test_fetchImages (self):
        data = {
            'images' : "0-0-0",
            'prefix' : "img_20130123_230004_2_10.0s_c1_calib"
        }
        rv = self.app.get ('/fetchImages', query_string=data)

        self.assertTrue (rv.data.find ('get_file') > -1 and
                         rv.data.find ('/bin/bash') > -1 and
                         rv.data.find ('fileURI') > -1 and
                         rv.data.find (data['prefix']) > -1)

    def test_listImages (self):
        rv = self.app.post ('/listImages', data=dict(
        ))
        obj = json.loads (rv.data)
        print obj
        images = obj['images']
        self.assertTrue (images[0] == 'mock-file-1' and 
                         images[1] == 'mock-file-2')
        
    def tearDown(self):
        pass

if __name__ == '__main__':
    unittest.main()

