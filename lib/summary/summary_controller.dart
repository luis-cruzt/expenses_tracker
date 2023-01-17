import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_expenses_tracker/services/firebase_service.dart';
import 'package:personal_expenses_tracker/services/models.dart';
import 'package:personal_expenses_tracker/summary/summary_state.dart';

/// Creating a provider that will be used to create a controller.
final summaryControllerProvider =
    StateNotifierProvider.autoDispose<SummaryController, SummaryState>((ref) {
  return SummaryController(
    const SummaryState(
      list: AsyncValue.data([]),
      globalList: AsyncValue.data([]),
    ),
    ref.watch(firebaseServiceProvider),
  );
});

/// It's a state notifier that loads the lists from the database
class SummaryController extends StateNotifier<SummaryState> {
  /// A constructor that is calling the super class constructor.
  SummaryController(
    super.state,
    this._firebaseService,
  );

  final FirebaseService _firebaseService;

  /// It deletes a list from the database.
  ///
  /// Args:
  ///   listName (String): The name of the list to be deleted.
  ///   isGlobal (bool): If the list is global or not.
  ///
  /// Returns:
  ///   A Future<ResponseModel>
  Future<ResponseModel> deleteList({
    required String listName,
    required bool isGlobal,
  }) async {
    final result = await _firebaseService.deleteList(
      listName: listName,
      isGlobal: isGlobal,
    );
    return result.fold(
      (l) => ResponseModel(ok: false, message: l.error),
      (r) => ResponseModel(ok: true, message: 'Lista eliminada exitosamente'),
    );
  }

  /// It deletes an expense from the database.
  ///
  /// Args:
  ///   id (String): The id of the expense to be deleted.
  ///   listName (String): The name of the list where the expense will be added.
  ///
  /// Returns:
  ///   A Future<ResponseModel>
  Future<ResponseModel> deleteExpense({
    required String id,
    required String listName,
  }) async {
    final result = await _firebaseService.deleteExpense(
      id: id,
      listName: listName,
    );
    return result.fold(
      (l) => ResponseModel(ok: false, message: l.error),
      (r) => ResponseModel(ok: true, message: 'Gasto eliminado exitosamente'),
    );
  }

  /// It adds a new expense to the database.
  ///
  /// Args:
  ///   expenseItem (ExpenseItem): The expense item to be added to the list.
  ///   listName (String): The name of the list where the expense will be added.
  ///
  /// Returns:
  ///   A Future<ResponseModel>
  Future<ResponseModel> addNewExpense({
    required ExpenseItem expenseItem,
    required String listName,
  }) async {
    final result = await _firebaseService.addNewExpense(
      expenseItem: expenseItem,
      listName: listName,
    );
    return result.fold(
      (l) => ResponseModel(ok: false, message: l.error),
      (r) => ResponseModel(ok: true, message: 'Gasto agregado exitosamente'),
    );
  }

  /// It adds a new list to the database.
  ///
  /// Args:
  ///   id (String): The name of the list to be added.
  ///
  /// Returns:
  ///   A Future<ResponseModel>
  Future<ResponseModel> addNewList({
    required String id,
    required bool isGlobal,
  }) async {
    final result =
        await _firebaseService.addNewList(listName: id, isGlobal: isGlobal);

    return result.fold(
      (l) => ResponseModel(ok: false, message: l.error),
      (r) => ResponseModel(ok: true, message: 'Lista agregada exitosamente'),
    );
  }

  /// It loads the lists from the database.
  Future<void> loadLists() async {
    state = state.copyWith(list: const AsyncValue.loading());
    final result = await _firebaseService.getLists();

    result.fold(
      (l) {
        state = state.copyWith(
          list: AsyncValue.error(
            'Error',
            StackTrace.fromString('Error on loading lists'),
          ),
        );
      },
      (r) {
        state = state.copyWith(list: AsyncValue.data(r));
      },
    );
  }

  /// It loads the lists from the database.
  Future<void> loadGlobalLists() async {
    state = state.copyWith(globalList: const AsyncValue.loading());
    final result = await _firebaseService.getGlobalLists();

    result.fold(
      (l) {
        state = state.copyWith(
          globalList: AsyncValue.error(
            l.error,
            StackTrace.fromString('Error on loading lists'),
          ),
        );
      },
      (r) {
        state = state.copyWith(globalList: AsyncValue.data(r));
      },
    );
  }
}
