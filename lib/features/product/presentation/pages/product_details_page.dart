import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/product_cubit.dart';
import '../../../../core/models/product.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  PageController _pageController = PageController(viewportFraction: 0.99);

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProduct(widget.productId);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E8B7B),
              ),
            );
          } else if (state is ProductLoaded) {
            return _buildProductDetails(context, state.product);
          } else if (state is ProductError) {
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
                    'Error loading product',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductCubit>().loadProduct(widget.productId);
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
    );
  }

  Widget _buildProductDetails(BuildContext context, Product product) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Off-white background
      body: Column(
        children: [
          // Green AppBar
          Container(
            color: const Color(0xFF2E8B7B),
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24), // Balance the back button
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Images with rounded corners
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                    child: SizedBox(
                      height: 260,
                      child: PageView.builder(
                        controller: _pageController,
                        padEnds: true,
                        pageSnapping: false,
                        physics: const BouncingScrollPhysics(),
                        clipBehavior: Clip.none,
                        onPageChanged: (_) {},
                        itemCount: product.images.isNotEmpty ? product.images.length : 1,
                        itemBuilder: (context, index) {
                          final imageUrl = product.images.isNotEmpty
                              ? product.images[index]
                              : product.thumbnail;
                          return Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              width: MediaQuery.of(context).size.width * 0.99,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.black.withOpacity(0.25), width: 1),
                                boxShadow: [
                                  // main drop shadow (below)
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.22),
                                    blurRadius: 22,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 10),
                                  ),
                                  // ambient soft halo around all sides
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.10),
                                    blurRadius: 40,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 0),
                                  ),
                                  // subtle top fade
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 28,
                                    spreadRadius: 0,
                                    offset: const Offset(0, -8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  color: const Color(0xFFF3EEF9),
                                  padding: const EdgeInsets.all(16),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                          size: 80,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Product Info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Price
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E8B7B),
                          ),
                        ),

                        const SizedBox(height: 8),
                        const Divider(height: 28, thickness: 0.8, color: Color(0xFFE0E0E0)),
                        const SizedBox(height: 8),

                        // Category and Rating
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE0B2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFF3C48F)),
                              ),
                              child: Text(
                                product.category.replaceAll('-', ' '),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF5A4638),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Icon(
                              Icons.star,
                              color: Color(0xFFF6B400),
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Description
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E8B7B),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Divider(height: 32, thickness: 0.8, color: Color(0xFFE0E0E0)),
                        const SizedBox(height: 8),

                        // Product Details as pills (wrap)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildSpecPill('Brand: ${product.brand}'),
                            _buildSpecPill('SKU: ${product.sku}'),
                            _buildSpecPill('Stock: ${product.stock}'),
                            _buildSpecPill('Status: ${product.availabilityStatus}'),
                            _buildSpecPill('Weight: ${product.weight} g'),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-1, -1), blurRadius: 1),
          BoxShadow(color: Color(0x14000000), offset: Offset(1, 1), blurRadius: 2),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          height: 1.0,
        ),
      ),
    );
  }
}
