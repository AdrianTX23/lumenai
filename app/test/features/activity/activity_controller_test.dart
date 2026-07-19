import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_app/features/activity/presentation/controllers/activity_controller.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  ActivityController controller() =>
      container.read(activityControllerProvider.notifier);
  ActivityFilterState state() => container.read(activityControllerProvider);

  group('ActivityController', () {
    test('starts unfiltered', () {
      expect(state().searchText, isEmpty);
      expect(state().category, isNull);
      expect(state().toFilter().searchText, isNull);
      expect(state().toFilter().category, isNull);
    });

    test('setSearch trims and maps empty to null in the filter', () {
      controller().setSearch('  uber  ');
      expect(state().searchText, 'uber');
      expect(state().toFilter().searchText, 'uber');

      controller().setSearch('   ');
      expect(state().toFilter().searchText, isNull);
    });

    test('toggleCategory selects, re-toggle clears', () {
      controller().toggleCategory(Category.dining);
      expect(state().category, Category.dining);

      controller().toggleCategory(Category.dining);
      expect(state().category, isNull);
    });

    test('switching category keeps search text', () {
      controller()
        ..setSearch('glovo')
        ..toggleCategory(Category.dining)
        ..toggleCategory(Category.transport);

      expect(state().category, Category.transport);
      expect(state().searchText, 'glovo');
    });
  });
}
