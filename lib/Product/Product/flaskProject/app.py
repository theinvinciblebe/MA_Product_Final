from flask import Flask, jsonify, request
from flask_cors import CORS
import sqlite3
import random

app = Flask(__name__)
CORS(app)

# Database connection
def get_db_connection():
    conn = sqlite3.connect('database.db', check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn     

try:
    conn = get_db_connection()
    # Perform database operations
except sqlite3.Error as e:
    return jsonify({"error": str(e)}), 500


# Endpoint to get all products
@app.route('/products', methods=['GET'])
def get_products():
    conn = get_db_connection()
    products = conn.execute('SELECT * FROM products').fetchall()
    conn.close()

    product_list = [
        {
            "id": product["id"],
            "title": product["title"],
            "price": product["price"],
            "description": product["description"],
            "image": f"https://picsum.photos/id/{random.randint(1, 1000)}/200/300",
            "rating": {
                "rate": 3.9,
                "count": 120
            }
        } for product in products
    ]
    return jsonify(product_list)

# New endpoint to get a single product by ID
@app.route('/products/<int:id>', methods=['GET'])
def get_product(id):
    conn = get_db_connection()
    product = conn.execute('SELECT * FROM products WHERE id = ?', (id,)).fetchone()
    conn.close()

    if product is None:
        return jsonify({"error": "Product not found"}), 404

    product_data = {
        "id": product["id"],
        "title": product["title"],
        "price": product["price"],
        "description": product["description"],
        "image": product["image"],
        "rating": {
            "rate": 3.9,
            "count": 120
        }
    }
    return jsonify(product_data)

# Endpoint to add a product
@app.route('/products', methods=['POST'])
def add_product():
    conn = get_db_connection()
    data = request.get_json()
    title = data.get('title')
    price = data.get('price')
    description = data.get('description')
    image = data.get('image')

    conn.execute(
        'INSERT INTO products (title, price, description, image) VALUES (?, ?, ?, ?)',
        (title, price, description, image)
    )
    conn.commit()
    conn.close()
    return jsonify({"message": "Product added successfully"}), 201

# Endpoint to delete a product by ID
@app.route('/products/<int:id>', methods=['DELETE'])
def delete_product(id):
    conn = get_db_connection()
    conn.execute('DELETE FROM products WHERE id = ?', (id,))
    conn.commit()
    conn.close()
    return jsonify({"message": "Product deleted successfully"}), 200

# Endpoint to update a product by ID
@app.route('/products/<int:id>', methods=['PUT'])
def update_product(id):
    conn = get_db_connection()
    data = request.get_json()
    title = data.get('title')
    price = data.get('price')
    description = data.get('description')
    image = data.get('image')

    conn.execute(
        'UPDATE products SET title = ?, price = ?, description = ?, image = ? WHERE id = ?',
        (title, price, description, image, id)
    )
    conn.commit()
    conn.close()
    return jsonify({"message": "Product updated successfully"}), 200

if __name__ == '__main__':
    app.run(debug=True)
