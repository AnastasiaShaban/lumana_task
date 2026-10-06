import 'package:get_it/get_it.dart';
import 'package:lumana_task/features/search/data/product_datasource.dart';
import 'package:lumana_task/features/search/data/product_repository_impl.dart';
import 'package:lumana_task/features/search/domain/product_repository.dart';
import 'api_client.dart';

final sl = GetIt.instance;

void setupDi() {
  sl.registerLazySingleton(() => ApiClient());
  sl.registerLazySingleton(() => ProductDatasource(sl()));
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl()),
  );
}
