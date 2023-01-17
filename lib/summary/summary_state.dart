// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_expenses_tracker/services/models.dart';

@immutable

/// `SummaryState` is a class that holds a list of `ExpenseItem` objects
class SummaryState {
  /// A constructor that takes in a list of ExpenseItem objects.
  const SummaryState({
    required this.list,
    required this.globalList,
  });

  /// A getter that returns the list of ExpenseItem objects.
  final AsyncValue<List<UserLists>> list;

  /// A global list that is used to store the list of all the users in the database.
  final AsyncValue<List<UserLists>> globalList;

  /// `copyWith` is a function that returns a new instance of the state with the properties that are
  /// passed in
  ///
  /// Args:
  ///   list (List<ExpenseItem>): The list of ExpenseItem objects.
  ///
  /// Returns:
  ///   A new instance of SummaryState with the updated list.
  SummaryState copyWith({
    AsyncValue<List<UserLists>>? list,
    AsyncValue<List<UserLists>>? globalList,
  }) {
    return SummaryState(
      list: list ?? this.list,
      globalList: globalList ?? this.globalList,
    );
  }
}
