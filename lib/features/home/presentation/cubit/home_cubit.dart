import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/models/category.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ApiService _apiService;

  HomeCubit(this._apiService) : super(HomeInitial());

  Future<void> loadCategories() async {
    emit(HomeLoading());
    try {
      // Get all products to extract categories with images
      final products = await _apiService.getAllProducts();
      final categories = <String, CategoryWithImage>{};
      
      // Extract unique categories with their first product image
      for (final product in products) {
        if (!categories.containsKey(product.category)) {
          categories[product.category] = CategoryWithImage(
            name: _formatCategoryName(product.category),
            image: product.thumbnail,
            slug: product.category,
          );
        }
      }
      
      emit(HomeLoaded(categories.values.toList()));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  String _formatCategoryName(String category) {
    return category
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
