import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/models/product.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ApiService _apiService;

  ProductCubit(this._apiService) : super(ProductInitial());

  Future<void> loadProduct(int id) async {
    emit(ProductLoading());
    try {
      final product = await _apiService.getProduct(id);
      emit(ProductLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
