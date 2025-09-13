import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/category.dart';

class ApiService {
  static const String baseUrl = 'https://dummyjson.com';

  // Get all products to extract categories
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?limit=0'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Failed to load products: $e');
    }
  }

  // Get categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/categories'),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> categoriesJson = json.decode(response.body);
        return categoriesJson.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  // Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/category/$category'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load products for category');
      }
    } catch (e) {
      throw Exception('Failed to load products for category: $e');
    }
  }

  // Search products
  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/search?q=$query'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> productsJson = data['products'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search products');
      }
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  // Get single product
  Future<Product> getProduct(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data);
      } else {
        throw Exception('Failed to load product');
      }
    } catch (e) {
      throw Exception('Failed to load product: $e');
    }
  }
}
