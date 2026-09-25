import 'package:flutter_test/flutter_test.dart';

import 'package:product_catalog/data/models/product.dart';

void main() {
  test('Product.fromJson maps API response correctly', () {
    final json = {
      'id': 1,
      'title': 'Test Phone',
      'description': 'A test product',
      'price': 999.99,
      'rating': 4.5,
      'thumbnail': 'https://example.com/phone.jpg',
      'images': [
        'https://example.com/phone-1.jpg',
        'https://example.com/phone-2.jpg',
      ],
    };

    final product = Product.fromJson(json);

    expect(product.id, 1);
    expect(product.title, 'Test Phone');
    expect(product.description, 'A test product');
    expect(product.price, 999.99);
    expect(product.rating, 4.5);
    expect(product.thumbnail, 'https://example.com/phone.jpg');

    expect(product.images, [
      'https://example.com/phone-1.jpg',
      'https://example.com/phone-2.jpg',
    ]);
  });

  test('Product.fromJson handles missing images', () {
    final json = {
      'id': 2,
      'title': 'Test Product',
      'description': 'Another test product',
      'price': 10,
      'rating': 4,
      'thumbnail': 'https://example.com/product.jpg',
    };

    final product = Product.fromJson(json);

    expect(product.images, isEmpty);
  });
}