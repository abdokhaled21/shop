import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';
import '../../../category/presentation/pages/category_page.dart';
import '../../../search/presentation/pages/search_page.dart';
import '../../../../core/models/category.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int get _displayedCategoryCount => 4; // change here to affect both Home and Search
  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Elite',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Derive the exact category slugs being shown in Home
                      final homeState = context.read<HomeCubit>().state;
                      List<String>? slugs;
                      if (homeState is HomeLoaded) {
                        final count = homeState.categories.length < _displayedCategoryCount
                            ? homeState.categories.length
                            : _displayedCategoryCount;
                        slugs = homeState.categories
                            .take(count)
                            .map((c) => c.slug)
                            .toList();
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchPage(categorySlugs: slugs),
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.search,
                      color: Color(0xFF2E8B7B),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
            
            // Collections Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'COLLECTIONS',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E8B7B),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Discover premium selections curated just for you',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Categories Grid
            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2E8B7B),
                      ),
                    );
                  } else if (state is HomeLoaded) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.6,
                            ),
                            padding: const EdgeInsets.only(top: 16),
                            itemCount: state.categories.length > _displayedCategoryCount
                                ? _displayedCategoryCount
                                : state.categories.length,
                            itemBuilder: (context, index) {
                              final category = state.categories[index];
                              return _buildCategoryCard(context, category, index);
                            },
                          ),
                        ),
                        // Top fade overlay: white -> transparent to hide shadows at the very top
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xFFF5F5F5),
                                    Color(0xFFF5F5F5).withOpacity(0.0),
                                  ],
                                  stops: const [0.0, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else if (state is HomeError) {
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
                            'Error loading categories',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<HomeCubit>().loadCategories();
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

  Widget _buildCategoryCard(BuildContext context, CategoryWithImage category, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryPage(
              categoryName: category.name,
              categorySlug: category.slug,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              Image.network(
                category.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 50,
                    ),
                  );
                },
              ),
              
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
              
              // Category Name
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Text(
                  category.name.toLowerCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
