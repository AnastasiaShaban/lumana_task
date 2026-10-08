import 'package:get_it/get_it.dart';
import 'package:lumana_task/core/api_client.dart';
import 'package:lumana_task/core/connectivity_service.dart';
import 'package:lumana_task/features/search/data/product_datasource.dart';
import 'package:lumana_task/features/search/data/product_local_datasource.dart';
import 'package:lumana_task/features/search/data/product_repository_impl.dart';
import 'package:lumana_task/features/search/domain/product_repository.dart';
import 'package:lumana_task/features/search/presentation/bloc/search_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDi() async {
  final prefs = await SharedPreferences.getInstance();

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerLazySingleton<ConnectivityService>(ConnectivityService.new)
    ..registerLazySingleton<ApiClient>(ApiClient.new)
    ..registerLazySingleton<ProductDatasource>(
      () => ProductDatasource(sl<ApiClient>()),
    )
    ..registerLazySingleton<ProductLocalDatasource>(
      () => ProductLocalDatasource(sl<Database>(), sl<SharedPreferences>()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(
        sl<ProductDatasource>(),
        sl<ProductLocalDatasource>(),
        sl<ConnectivityService>(),
      ),
    )
    ..registerFactory<SearchBloc>(() => SearchBloc(sl<ProductRepository>()));
}
