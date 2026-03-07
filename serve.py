#!/usr/bin/env python3
import os
import sys
from http.server import HTTPServer, SimpleHTTPRequestHandler

class FlutterHTTPRequestHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        # Route all requests to index.html for Flutter routing
        if self.path == '/' or not os.path.splitext(self.path)[1]:
            self.path = '/index.html'
        return super().do_GET()

if __name__ == '__main__':
    os.chdir('build/web')
    server = HTTPServer(('127.0.0.1', 8891), FlutterHTTPRequestHandler)
    print('Server running at http://127.0.0.1:8891')
    server.serve_forever()
