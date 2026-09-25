import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductPage {
  final List<Product> products;
  final int total;

  ProductPage({
    required this.products,
    required this.total,
  });
}

class ProductApi {
  static const String baseUrl = 'https://dummyjson.com';

  Future<ProductPage> getProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products?limit=$limit&skip=$skip'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load products');
    }

    final data = jsonDecode(response.body);

    final List products = data['products'];

    return ProductPage(
      products: products
          .map((json) => Product.fromJson(json))
          .toList(),
      total: data['total'],
    );
  }

  // 👇 TAMBAH METHOD INI DI SINI
  Future<Product> getProductById(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/products/$id'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load product');
    }

    final data = jsonDecode(response.body);

    return Product.fromJson(data);
  }
}