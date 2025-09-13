import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/models/product.dart';

part 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final ApiService _apiService;
  List<Product>? _homeProducts; // cached subset to mirror home data

  SearchCubit(this._apiService) : super(SearchInitial());

  Future<void> loadAllProducts() async {
    emit(SearchLoading());
    try {
      // 1) Get all products to extract the same first 4 categories as Home
      final allProducts = await _apiService.getAllProducts();
      final List<String> categoryOrder = [];
      for (final p in allProducts) {
        if (!categoryOrder.contains(p.category)) {
          categoryOrder.add(p.category);
          if (categoryOrder.length >= 4) break;
        }
      }

      // 2) Fetch products for those 4 categories
      final futures = categoryOrder
          .map((slug) => _apiService.getProductsByCategory(slug))
          .toList();
      final results = await Future.wait(futures);

      // 3) Merge results into a single list
      final merged = <Product>[];
      for (final list in results) {
        merged.addAll(list);
      }

      _homeProducts = merged;
      emit(SearchLoaded(_homeProducts!));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> loadFromCategorySlugs(List<String> slugs) async {
    emit(SearchLoading());
    try {
      final futures = slugs.map((slug) => _apiService.getProductsByCategory(slug)).toList();
      final results = await Future.wait(futures);
      final merged = <Product>[];
      for (final list in results) {
        merged.addAll(list);
      }
      _homeProducts = merged;
      emit(SearchLoaded(_homeProducts!));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> searchProducts(String query) async {
    // Ensure we have the home subset
    if (_homeProducts == null) {
      await loadAllProducts();
    }

    // If empty query, just show the cached home subset
    if (query.isEmpty) {
      emit(SearchLoaded(_homeProducts ?? []));
      return;
    }

    // Local filter within the home subset only
    final lower = query.toLowerCase();
    final filtered = (_homeProducts ?? [])
        .where((p) =>
            p.title.toLowerCase().contains(lower) ||
            p.category.toLowerCase().contains(lower))
        .toList();
    emit(SearchLoaded(filtered));
  }
}
