# =============================================
# Auth Service
# Author: Surya
# Description: Handles authentication and returns
#              a mock JWT token
# =============================================

from flask import Flask, jsonify, request
import hashlib
import base64
import time

app = Flask(__name__)

# Mock user database — in real apps this would be a DB!
USERS = {
    'surya': 'password123',
    'admin': 'admin123'
}


@app.route('/')
def home():
    return jsonify({
        'service': 'auth-service',
        'status': 'running',
        'version': '1.0.0'
    })


@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200


@app.route('/login', methods=['POST'])
def login():
    """Authenticates user and returns a mock JWT token"""
    data = request.get_json()

    if not data or 'username' not in data or 'password' not in data:
        return jsonify({'error': 'Username and password required'}), 400

    username = data['username']
    password = data['password']

    # Check credentials
    if username in USERS and USERS[username] == password:
        # Generate a fake token (not real JWT — just for demo)
        token_data = f"{username}:{int(time.time())}"
        token = base64.b64encode(
            hashlib.sha256(token_data.encode()).digest()
        ).decode()

        return jsonify({
            'message': 'Login successful',
            'username': username,
            'token': token,
            'expires_in': 3600
        }), 200

    return jsonify({'error': 'Invalid credentials'}), 401


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)