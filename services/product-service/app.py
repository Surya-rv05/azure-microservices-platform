# =============================================
# Product Service
# Author: Surya
# Description: Returns a list of products
# =============================================

from flask import Flask, jsonify

app = Flask(__name__)

# Mock product database
PRODUCTS = [
    {'id': 1, 'name': 'Laptop', 'price': 60000, 'stock': 15},
    {'id': 2, 'name': 'Phone', 'price': 30000, 'stock': 42},
    {'id': 3, 'name': 'Headphones', 'price': 3000, 'stock': 128},
    {'id': 4, 'name': 'Keyboard', 'price': 2500, 'stock': 56},
    {'id': 5, 'name': 'Mouse', 'price': 1200, 'stock': 89}
]


@app.route('/')
def home():
    return jsonify({
        'service': 'product-service',
        'status': 'running',
        'version': '1.0.0'
    })


@app.route('/health')
def health():
    return jsonify({'status': 'healthy'}), 200


@app.route('/products')
def products():
    """Returns list of all products"""
    return jsonify({
        'count': len(PRODUCTS),
        'products': PRODUCTS
    })


@app.route('/products/<int:product_id>')
def get_product(product_id):
    """Returns a specific product by ID"""
    product = next((p for p in PRODUCTS if p['id'] == product_id), None)
    if product:
        return jsonify(product)
    return jsonify({'error': 'Product not found'}), 404


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)