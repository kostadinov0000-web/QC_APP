#!/usr/bin/env python3
"""
Simple script to run the Quality Control Application
"""

import os
import sys

# Add the current directory to Python path
sys.path.insert(0, os.path.dirname(__file__))

from app import app, init_db

if __name__ == '__main__':
    # Initialize database
    init_db()
    
    # Get configuration
    host = os.environ.get('FLASK_HOST', '127.0.0.1')
    port = int(os.environ.get('FLASK_PORT', 5000))
    debug = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
    
    # Run the application
    app.run(host=host, port=port, debug=debug) 