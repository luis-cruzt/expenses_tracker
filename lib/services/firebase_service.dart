import 'package:dartz/dartz.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_expenses_tracker/auth/auth_service.dart';
import 'package:personal_expenses_tracker/services/models.dart';

/// It's creating a provider for the FirebaseService.
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseServiceImpl();
});

/// It's an abstract class that has a method called getExpenses that returns a list of ExpenseItem
/// objects
abstract class FirebaseService {
  /// It's a method that returns the lists of the user
  Future<Either<Failure, List<UserLists>>> getLists();

  /// It's deleting a list from the database.
  Future<Either<Failure, Success>> deleteList({
    required String listName,
    required bool isGlobal,
  });

  /// It's deleting an expense from the database.
  Future<Either<Failure, Success>> deleteExpense({
    required String id,
    required String listName,
  });

  /// It's getting the global lists from the database.
  Future<Either<Failure, List<UserLists>>> getGlobalLists();

  /// It's adding a new list to the database.
  Future<Either<Failure, Success>> addNewList({
    required String listName,
    required bool isGlobal,
  });

  /// It's adding a new expense to the database.
  Future<Either<Failure, Success>> addNewExpense({
    required bool isGlobal,
    required String listName,
    required ExpenseItem expenseItem,
  });

  /// It's a method that returns a list of ExpenseItem objects.
  Future<List<ExpenseItem>> getExpenses({required String listId});
}

/// It's a wrapper around the FirebaseDatabase class that exposes a single method, getExpenses, which
/// returns a list of ExpenseItem objects
class FirebaseServiceImpl implements FirebaseService {
  /// It's creating a reference to the Firebase database.
  final ref = FirebaseDatabase.instance;

  /// > Get the data from the Firebase database, and return a list of ExpenseItem objects
  ///
  /// Args:
  ///   listId (String): The id of the list you want to get the expenses from.
  ///
  /// Returns:
  ///   A list of ExpenseItem objects.
  @override
  Future<List<ExpenseItem>> getExpenses({required String listId}) async {
    final expensesList = <ExpenseItem>[];

    final data = await ref.ref(listId).once();

    Map<String, dynamic>.from(
      data.snapshot.value! as Map<Object?, Object?>,
    ).forEach((name, expenses) {
      if (expenses is Map) {
        expenses.forEach((expenseName, expenseData) {
          final item = ExpenseItem.fromMap(
            Map<String, dynamic>.from(expenseData as Map),
            name,
          );
          expensesList.add(item);
        });
      }
    });

    return expensesList;
  }

  @override
  Future<Either<Failure, List<UserLists>>> getLists() async {
    try {
      final uid = await _getUid();
      final userLists = <UserLists>[];
      final data = await ref.ref(uid).once();

      if (data.snapshot.value != null) {
        Map<String, dynamic>.from(
          data.snapshot.value! as Map<Object?, Object?>,
        ).forEach((name, expenses) {
          final expenseList = <ExpenseItem>[];
          if (expenses is Map) {
            expenses.forEach((expenseName, expenseData) {
              final item = ExpenseItem.fromMap(
                Map<String, dynamic>.from(expenseData as Map),
                expenseName.toString(),
              );
              expenseList.add(item);
            });
          }
          userLists.add(UserLists(name: name, expenses: expenseList));
        });
      }

      return Right(userLists);
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  /// If the user is not signed in, sign them out
  ///
  /// Returns:
  ///   A Future<String>
  Future<String> _getUid() async {
    final uid = AuthService().user?.uid;
    if (uid == null) await AuthService().signOut();
    return uid!;
  }

  @override
  Future<Either<Failure, Success>> addNewList({
    required String listName,
    required bool isGlobal,
  }) async {
    try {
      final uid = await _getUid();
      if (isGlobal) {
        await ref.ref().child('global_lists/$listName').set('null');
      } else {
        await ref.ref().child('$uid/$listName').set('null');
      }
      return Right(Success(ok: true));
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserLists>>> getGlobalLists() async {
    try {
      final userLists = <UserLists>[];
      final data = await ref.ref('global_lists').once();

      if (data.snapshot.value != null) {
        Map<String, dynamic>.from(
          data.snapshot.value! as Map<Object?, Object?>,
        ).forEach((name, expenses) {
          final expenseList = <ExpenseItem>[];
          if (expenses is Map) {
            expenses.forEach((expenseName, expenseData) {
              final item = ExpenseItem.fromMap(
                Map<String, dynamic>.from(expenseData as Map),
                expenseName.toString(),
              );
              expenseList.add(item);
            });
          }
          userLists.add(UserLists(name: name, expenses: expenseList));
        });
      }

      return Right(userLists);
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> addNewExpense({
    required bool isGlobal,
    required String listName,
    required ExpenseItem expenseItem,
  }) async {
    try {
      final uid = await _getUid();
      final expenseId =
          ref.ref(isGlobal ? 'global_lists' : uid).child(listName).push().key;
      final expenseItemFinal = expenseItem.copyWith(id: expenseId);
      await ref
          .ref(isGlobal ? 'global_lists' : uid)
          .child('$listName/$expenseId')
          .update(expenseItemFinal.toMap());
      return Right(Success(ok: true));
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> deleteExpense({
    required String id,
    required String listName,
  }) async {
    try {
      final uid = await _getUid();
      await ref.ref(uid).child('$listName/$id').remove();

      return Right(Success(ok: true));
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Success>> deleteList({
    required String listName,
    required bool isGlobal,
  }) async {
    try {
      if (isGlobal) {
        await ref.ref('global_lists').child(listName).remove();
      } else {
        final uid = await _getUid();
        await ref.ref(uid).child(listName).remove();
      }
      return Right(Success(ok: true));
    } catch (e) {
      return Left(Failure(error: e.toString()));
    }
  }
}
