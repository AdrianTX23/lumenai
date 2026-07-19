import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/di/di.dart';

/// Immutable filter state of the activity feed.
final class ActivityFilterState {
  /// Creates the filter state.
  const ActivityFilterState({this.searchText = '', this.category});

  /// Free-text query (merchant or note).
  final String searchText;

  /// Selected category chip, `null` = all.
  final Category? category;

  /// Copy with updates. Category uses a sentinel so `null` can be set.
  ActivityFilterState copyWith({
    String? searchText,
    Object? category = _unset,
  }) {
    return ActivityFilterState(
      searchText: searchText ?? this.searchText,
      category:
          identical(category, _unset) ? this.category : category as Category?,
    );
  }

  static const _unset = Object();

  /// The domain filter for the current UI state.
  TransactionFilter toFilter() => TransactionFilter(
        searchText: searchText.isEmpty ? null : searchText,
        category: category,
        limit: 200,
      );
}

/// UI state machine for the activity filters.
final class ActivityController extends Notifier<ActivityFilterState> {
  @override
  ActivityFilterState build() => const ActivityFilterState();

  /// Updates the free-text query.
  void setSearch(String text) =>
      state = state.copyWith(searchText: text.trim());

  /// Selects a category chip; selecting the active one clears it.
  void toggleCategory(Category category) => state = state.copyWith(
        category: state.category == category ? null : category,
      );

  /// Clears the category filter.
  void clearCategory() => state = state.copyWith(category: null);
}

/// The activity filter state.
final activityControllerProvider =
    NotifierProvider<ActivityController, ActivityFilterState>(
  ActivityController.new,
);

/// The filtered feed reacting to both DB writes and filter changes.
final activityFeedProvider = StreamProvider<List<Transaction>>((ref) {
  final filter = ref.watch(activityControllerProvider).toFilter();
  return ref.watch(observeTransactionsProvider)(filter);
});

/// Applies a user recategorization and exposes the outcome to the sheet.
final recategorizeProvider =
    Provider<Future<Result<void>> Function(TransactionId, Category)>(
  (ref) =>
      (id, category) => ref.read(recategorizeTransactionProvider)(id, category),
);
