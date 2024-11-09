import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'cart_manager.dart';
import 'FavoritesManager.dart';
import 'cart.dart';
import 'FavoritesScreen.dart';
import 'detail.dart';
import 'package:badges/badges.dart' as badges_pkg;

class ProductList extends StatefulWidget {
  const ProductList({super.key});

  @override
  State<ProductList> createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  Future<List>? _myFuture;
  List products = [];
  String searchQuery = '';



  @override
  void initState() {
    super.initState();
    _myFuture = _getProducts();
  }

  Future<List> _getProducts() async {
    var url = Uri.parse("http://192.168.0.183:5050/products");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      products = jsonDecode(response.body);
      return products;
    } else {
      throw Exception("Failed to load products");
    }
  }

  void _filterProducts(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  List get filteredProducts {
    if (searchQuery.isEmpty) {
      return products;
    }
    return products
        .where((product) =>
        product['title'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  void _showCreateProductForm() {
    final titleController = TextEditingController();
    final detailController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: detailController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text;
              final description = detailController.text;
              final priceText = priceController.text;
              final price = double.tryParse(priceText) ?? 0.0;

              if (title.isEmpty || price == 0.0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter a valid title and price")),
                );
                return;
              }

              final productData = {
                'title': title,
                'description': description,
                'price': price,
                'image': 'https://picsum.photos/200/300',
              };

              _addProduct(productData);
              Navigator.of(ctx).pop();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addProduct(Map productData) async {
    var url = Uri.parse("http://192.168.0.183:5050/products");

    var response = await http.post(url, body: jsonEncode(productData), headers: {"Content-Type": "application/json"});
    if (response.statusCode == 201) {
      setState(() {
        _myFuture = _getProducts();
      });
    } else {
      throw Exception("Failed to add product");
    }
  }

  void _showEditProductForm(Map product) {
    final titleController = TextEditingController(text: product['title']);
    final detailController = TextEditingController(text: product['description']);
    final priceController = TextEditingController(text: product['price'].toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: detailController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text;
              final description = detailController.text;
              final priceText = priceController.text;
              final price = double.tryParse(priceText) ?? 0.0;

              if (title.isEmpty || price == 0.0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please enter a valid title and price")),
                );
                return;
              }

              final updatedProductData = {
                'title': title,
                'description': description,
                'price': price,
                'image': product['image'],
              };

              _editProduct(product['id'], updatedProductData);
              Navigator.of(ctx).pop();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _editProduct(int productId, Map updatedProductData) async {
    var url = Uri.parse("http://192.168.0.183:5050/products/$productId");

    var response = await http.put(
      url,
      body: jsonEncode(updatedProductData),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      setState(() {
        _myFuture = _getProducts();
      });
    } else {
      throw Exception("Failed to update product");
    }
  }

  Future<void> _confirmDeleteProduct(int productId) async {
    // Show confirmation dialog
    bool? confirmed = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    // If confirmed, delete the product
    if (confirmed == true) {
      await _deleteProduct(productId);
    }
  }

  Future<void> _deleteProduct(int productId) async {
    var url = Uri.parse("http://192.168.0.183:5050/products/$productId");

    var response = await http.delete(url);
    if (response.statusCode == 200) {
      setState(() {
        _myFuture = _getProducts();
      });
    } else {
      throw Exception("Failed to delete product");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Products",
          style: TextStyle(
              color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Consumer<CartManager>(
            builder: (_, cartManager, __) => InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CartScreen()),
                );
              },
              child: badges_pkg.Badge(
                badgeContent: Text(
                  "${cartManager.cartItems.length}",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
                child: Icon(Icons.shopping_cart, color: Colors.blue),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Consumer<FavoritesManager>(
            builder: (_, favoritesManager, __) => InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesScreen()),
                );
              },
              child: badges_pkg.Badge(
                badgeContent: Text(
                  "${favoritesManager.favoriteCount}",
                  style: TextStyle(fontSize: 10, color: Colors.white),
                ),
                child: Icon(Icons.favorite, color: Colors.redAccent),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProductForm,
        child: Icon(Icons.add_box_rounded),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.network(
              'https://images.pexels.com/photos/6214457/pexels-photo-6214457.jpeg?auto=compress&cs=tinysrgb&w=600',
              fit: BoxFit.cover,
            ),
          ),
          FutureBuilder<List>(
            future: _myFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text("Error loading products"));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text("No products found"));
              }

              var displayedProducts = filteredProducts;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      onChanged: _filterProducts,
                      decoration: InputDecoration(
                        hintText: "Search product",
                        prefixIcon: Icon(Icons.search, color: Colors.blue),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: GridView.builder(
                        itemCount: displayedProducts.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.75,
                        ),
                        itemBuilder: (context, index) {
                          var product = displayedProducts[index] as Map<String, dynamic>;
                          var imageUrl = product['image'] ?? '';
                          var title = product['title'] ?? 'No Title';
                          var price = product['price'] ?? 0.0;
                          var description = product['description'] ?? 'No Description';

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(
                                    data: product['id'],
                                    imageUrl: imageUrl,
                                  ),
                                ),
                              );
                            },
                            child: Consumer<FavoritesManager>(
                              builder: (context, favoritesManager, _) {
                                bool isFavorite = favoritesManager.isFavorite(product['id']);
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 5,
                                  shadowColor: Colors.black26,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(10.0),
                                                topRight: Radius.circular(10.0),
                                              ),
                                              child: Image.network(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return Container(
                                                    width: double.infinity,
                                                    height: 130,
                                                    color: Colors.grey[300],
                                                    child: const Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                      size: 40,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: IconButton(
                                                icon: Icon(
                                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                                  color: isFavorite ? Colors.redAccent : Colors.white,
                                                ),
                                                onPressed: () {
                                                  favoritesManager.toggleFavorite(product);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Text(
                                          description,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 10,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
// Add this inside the GridView.builder within your ProductList widget

                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "\$${price.toString()}",
                                              style: const TextStyle(
                                                color: Colors.green,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                Provider.of<CartManager>(context, listen: false).addItem({
                                                  'id': product['id'],
                                                  'title': title,
                                                  'description': description,
                                                  'price': price,
                                                  'image': imageUrl,
                                                });
                                              },
                                              icon: Icon(
                                                Icons.shopping_cart_rounded,
                                                color: Colors.orangeAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                _showEditProductForm(product);
                                              },
                                              icon: Icon(Icons.edit, color: Colors.blueAccent),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                _confirmDeleteProduct(product['id']);
                                              },
                                              icon: Icon(Icons.delete, color: Colors.redAccent),
                                            ),
                                          ],
                                        ),
                                      )


                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

}
