import 'dart:async';

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
  final TextEditingController _searchController =
      TextEditingController();

  Timer? _searchDebounce;

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
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ========================================
  // LOAD PRODUCTS
  // ========================================

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

  // ========================================
  // SEARCH DEBOUNCE
  // ========================================

  void _onSearchChanged(String query) {
    setState(() {});

    _searchDebounce?.cancel();

    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () {
        final trimmedQuery = query.trim();

        if (trimmedQuery.isEmpty) {
          _loadProducts();
        } else {
          _searchProducts(trimmedQuery);
        }
      },
    );
  }

  // ========================================
  // SEARCH PRODUCTS
  // ========================================

  Future<void> _searchProducts(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _products.clear();
      _total = 0;
    });

    try {
      final page = await _api.searchProducts(
        query: query,
        limit: _pageSize,
        skip: 0,
      );

      setState(() {
        _products.addAll(page.products);
        _total = page.total;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to search products.';
        _isLoading = false;
      });
    }
  }

  // ========================================
  // PULL TO REFRESH
  // ========================================

  Future<void> _refreshProducts() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      await _loadProducts();
    } else {
      await _searchProducts(query);
    }
  }

  // ========================================
  // LOAD MORE PRODUCTS
  // ========================================

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || _products.length >= _total) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final query = _searchController.text.trim();

      final ProductPage page;

      if (query.isEmpty) {
        page = await _api.getProducts(
          limit: _pageSize,
          skip: _products.length,
        );
      } else {
        page = await _api.searchProducts(
          query: query,
          limit: _pageSize,
          skip: _products.length,
        );
      }

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

  // ========================================
  // SCROLL LISTENER
  // ========================================

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMoreProducts();
    }
  }

  // ========================================
  // BUILD SCREEN
  // ========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();

                          setState(() {});

                          _loadProducts();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  // ========================================
  // BUILD BODY
  // ========================================

  Widget _buildBody() {
    // Initial loading
    if (_isLoading && _products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (_error != null && _products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(_error!),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _refreshProducts,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (_products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
            ),
            SizedBox(height: 12),
            Text(
              'No products found.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // Product list
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _products.length + 1,
        itemBuilder: (context, index) {
          // Bottom section
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
      ),
    );
  }
}