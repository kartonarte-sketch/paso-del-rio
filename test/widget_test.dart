import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:paso_del_rio/app/app.dart';
import 'package:paso_del_rio/app/app_state.dart';
import 'package:paso_del_rio/core/data/local_database.dart';
import 'package:paso_del_rio/core/data/restaurant_repository.dart';

void main() {
  testWidgets('muestra la pantalla de acceso', (tester) async {
    final database = LocalDatabase();
    await database.open();
    final repository = RestaurantRepository(database);
    final appState = AppState(repository);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: appState,
        child: const App(),
      ),
    );

    expect(find.text('Paso del Río'), findsWidgets);
    expect(find.text('Ingresar'), findsWidgets);
  });
}
