import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../cubit/search_cubit.dart';
import '../../../product/presentation/pages/product_details_page.dart';
import '../../../../core/models/product.dart';

class SearchPage extends StatefulWidget {
  final List<String>? categorySlugs;
  const SearchPage({super.key, this.categorySlugs});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    // Load from Home-provided category slugs if available, else fallback
    final slugs = widget.categorySlugs;
    if (slugs != null && slugs.isNotEmpty) {
      context.read<SearchCubit>().loadFromCategorySlugs(slugs);
    } else {
      context.read<SearchCubit>().loadAllProducts();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_currentQuery != query) {
      _currentQuery = query;
      context.read<SearchCubit>().searchProducts(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Match CategoryPage background
      backgroundColor: const Color(0xFFF0EDE8),
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Color(0xFF2E8B7B),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF2E8B7B),
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                  child: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Results
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E8B7B),
                      ),
                    );
                  } else if (state is SearchLoaded) {
                    if (state.products.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentQuery.isEmpty 
                                  ? 'Start typing to search products'
                                  : 'No products found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (_currentQuery.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Try searching with different keywords',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            _currentQuery.isEmpty
                                ? '${state.products.length} Products found'
                                : '${state.products.length} Products found for "${_currentQuery}"',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF654321), // same tone used in CategoryPage
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: MasonryGridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              itemCount: state.products.length,
                              itemBuilder: (context, index) {
                                final product = state.products[index];
                                // Create random-looking card sizes with a higher minimum to avoid very small cards
                                final cardSizes = [1.2, 1.35, 1.5, 1.65, 1.8, 2.0];
                                final heightMultiplier = cardSizes[index % cardSizes.length];
                                return _buildProductCard(context, product, heightMultiplier);
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (state is SearchError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading products',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              if (_currentQuery.isEmpty) {
                                context.read<SearchCubit>().loadAllProducts();
                              } else {
                                context.read<SearchCubit>().searchProducts(_currentQuery);
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, double heightMultiplier) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                height: (120 * heightMultiplier).clamp(130, 250),
                width: double.infinity,
                child: Stack(
                  children: [
                    Image.network(
                      product.thumbnail,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 50,
                          ),
                        );
                      },
                    ),
                    // Rating badge like CategoryPage
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E8B7B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Product Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  // Product Name
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    softWrap: true,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Price
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E8B7B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
