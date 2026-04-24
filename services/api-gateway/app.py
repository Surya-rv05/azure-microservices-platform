# =============================================
# API Gateway Service
# Author: Surya
# Description: Entry point that routes requests
#              to Auth and Product services
# =============================================

from flask import Flask, jsonify, request
import requests
import os

app = Flask(__name__)

# Read downstream service URLs from environment variables
# This is industry standard — never hardcode URLs!
AUTH_SERVICE_URL = os.getenv('AUTH_SERVICE_URL', 'http://auth-service:5001')
PRODUCT_SERVICE_URL = os.getenv('PRODUCT_SERVICE_URL', 'http://product-service:5002')


@app.route('/')
def home():
    return jsonify({
        'service': 'api-gateway',
        'status': 'running',
        'version': '1.0.0',
        'endpoints': {
            '/health': 'Health check',
            '/login': 'Forwards to auth service',
            '/products': 'Forwards to product service'
        }
    })


@app.route('/health')
def health():
    """Kubernetes uses this to check if service is alive"""
    return jsonify({'status': 'healthy'}), 200


@app.route('/login', methods=['POST'])
def login():
    """Forwards login request to auth service"""
    try:
        response = requests.post(
            f'{AUTH_SERVICE_URL}/login',
            json=request.get_json(),
            timeout=5
        )
        return jsonify(response.json()), response.status_code
    except requests.exceptions.RequestException as e:
        return jsonify({'error': 'Auth service unavailable', 'details': str(e)}), 503


@app.route('/products')
def products():
    """Forwards product request to product service"""
    try:
        response = requests.get(f'{PRODUCT_SERVICE_URL}/products', timeout=5)
        return jsonify(response.json()), response.status_code
    except requests.exceptions.RequestException as e:
        return jsonify({'error': 'Product service unavailable', 'details': str(e)}), 503


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)