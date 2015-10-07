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

class EvryTestCase(unittest.TestCase):

    def setUp(self):
        evry.app.config['TESTING'] = True
        evry.conn = get_mock_connection ()
        self.app = evry.app.test_client()

    def test_root (self):
        rv = self.app.get('/')
        self.assertTrue (rv.data.startswith ('<!doctype html>'))
        self.assertTrue (rv.data.endswith ('</html>'))

    def test_login (self):
        rv = evry.app.test_client().post('/query', data=dict(
            query='select * from images'
        ))
        obj = json.loads (rv.data)
        self.assertEqual (obj['curves'][0]['curve'], 'x')

    def tearDown(self):
        pass

if __name__ == '__main__':
    unittest.main()

