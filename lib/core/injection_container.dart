import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumana_task/core/api_client.dart';
import 'package:lumana_task/core/connectivity_service.dart';
import 'package:lumana_task/features/search/data/product_datasource.dart';
import 'package:lumana_task/features/search/data/product_local_datasource.dart';
import 'package:lumana_task/features/search/data/product_repository_impl.dart';
import 'package:lumana_task/features/search/domain/product_repository.dart';
import 'package:lumana_task/features/search/presentation/bloc/search_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDi() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(prefs);

  sl.registerLazySingleton(() => ConnectivityService());
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => ProductDatasource(sl()));
  sl.registerLazySingleton(() => ProductLocalDatasource(sl()));
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl(), sl(), sl()),
  );
  sl.registerFactory(() => SearchBloc(sl()));
}
