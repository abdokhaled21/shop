import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/models/product.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final ApiService _apiService;

  CategoryCubit(this._apiService) : super(CategoryInitial());

  Future<void> loadCategoryProducts(String category) async {
    emit(CategoryLoading());
    try {
      final products = await _apiService.getProductsByCategory(category);
      emit(CategoryLoaded(products));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
