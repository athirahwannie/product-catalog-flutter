import 'package:flutter/material.dart';

import '../../data/models/product.dart';
import '../../data/services/product_api.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductApi _api = ProductApi();
  final ScrollController _scrollController = ScrollController();

  final List<Product> _products = [];

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  int _total = 0;

  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final page = await _api.getProducts(
        limit: _pageSize,
        skip: 0,
      );

      setState(() {
        _products.clear();
        _products.addAll(page.products);
        _total = page.total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load products.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || _products.length >= _total) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final page = await _api.getProducts(
        limit: _pageSize,
        skip: _products.length,
      );

      setState(() {
        _products.addAll(page.products);
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return const Center(
        child: Text('No products found.'),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _products.length + 1,
      itemBuilder: (context, index) {
        if (index == _products.length) {
          if (_isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (_products.length >= _total) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text('No more products'),
              ),
            );
          }

          return const SizedBox.shrink();
        }

        final product = _products[index];

        return ProductCard(
            product: product,
             onTap: () {
                Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
              productId: product.id,
        ),
      ),
    );
  },
);
      },
    );
  }
}