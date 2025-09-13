import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/category/presentation/cubit/category_cubit.dart';
import 'features/product/presentation/cubit/product_cubit.dart';
import 'features/search/presentation/cubit/search_cubit.dart';
import 'core/services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => HomeCubit(ApiService())),
        BlocProvider(create: (context) => CategoryCubit(ApiService())),
        BlocProvider(create: (context) => ProductCubit(ApiService())),
        BlocProvider(create: (context) => SearchCubit(ApiService())),
      ],
      child: MaterialApp(
        title: 'Elite Collections',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          fontFamily: 'Roboto',
        ),
        home: const HomePage(),
      ),
    );
  }
}
