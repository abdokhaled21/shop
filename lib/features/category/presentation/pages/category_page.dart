import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../cubit/category_cubit.dart';
import '../../../product/presentation/pages/product_details_page.dart';
import '../../../../core/models/product.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;
  final String categorySlug;

  const CategoryPage({
    super.key,
    required this.categoryName,
    required this.categorySlug,
  });

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().loadCategoryProducts(widget.categorySlug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EDE8), // Beige background color
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
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
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.categoryName.toLowerCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E8B7B),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24), // Balance the back button
                ],
              ),
            ),
            
            // Products Grid
            Expanded(
              child: BlocBuilder<CategoryCubit, CategoryState>(
                builder: (context, state) {
                  if (state is CategoryLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E8B7B),
                      ),
                    );
                  } else if (state is CategoryLoaded) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Text(
                            '${state.products.length} Products',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF654321), // Darker brown color
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
                                final cardHeight = cardSizes[index % cardSizes.length];
                                
                                return _buildProductCard(context, product, cardHeight);
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (state is CategoryError) {
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
                              context.read<CategoryCubit>().loadCategoryProducts(widget.categorySlug);
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
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: heightMultiplier > 1.5 ? 60 : 40,
                          ),
                        );
                      },
                    ),
                    // Rating badge positioned on image
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
