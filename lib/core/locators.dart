import 'package:asm_wt/service/RESTAPI/geofencing_service.dart';
import 'package:get_it/get_it.dart';

/// Locators to get instances of classes mostly singletons
GetIt locator = GetIt.I;

/// needs to be called at in the main
/// it creates the instances of services
void setupLocators() {
  locator.registerLazySingleton<GeoFencingService>(
    () => GeoFencingService(),
  );
}
