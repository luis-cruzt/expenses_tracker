// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// `Failure` is a class that represents an error that occurred in the app
class Failure {
  /// It's a named constructor that takes an error string and sets the error property to the value of
  /// the error string.
  Failure({
    required this.error,
  });

  /// It's a variable that is set to a value when the object is created and can't be changed.
  final String error;
}

/// It's a class that has two properties, ok and message, and a named constructor that takes two
/// arguments and sets the value of the ok and message properties to the value of the arguments
class ResponseModel {
  /// It's a named constructor that takes two arguments and sets the value of the ok and message
  /// properties to the value of the arguments.
  ResponseModel({
    required this.ok,
    required this.message,
  });

  /// It's a variable that is set to a value when the object is created and can't be changed.
  final bool ok;

  /// It's a variable that is set to a value when the object is created and can't be changed.
  final String message;
}

/// `Success` is a class that represents an error that occurred in the app
class Success {
  /// It's a named constructor that takes an error string and sets the error property to the value of
  /// the error string.
  Success({
    required this.ok,
  });

  /// It's a variable that is set to a value when the object is created and can't be changed.
  final bool ok;
}

/// It's a class that represents an expense item

class ExpenseItem {
  /// A named constructor.
  ExpenseItem({
    required this.name,
    required this.id,
    required this.descr,
    required this.value,
    required this.date,
    required this.category,
    required this.uid,
  });

  /// It creates a new ExpenseItem object from a map.
  ///
  /// Args:
  ///   map (Map<String, dynamic>): The map to convert into an object.
  ///
  /// Returns:
  ///   A new ExpenseItem object.
  factory ExpenseItem.fromMap(Map<String, dynamic> map, String id) {
    return ExpenseItem(
      name: map['name'] as String,
      descr: map['descr'] as String,
      value: (map['value'] as int) / 100,
      id: id,
      date: map['date'] as String,
      category: map['category'] == 'personal'
          ? ExpenseCategoryEnum.personal
          : ExpenseCategoryEnum.house,
      uid: map['uid'] as String,
    );
  }

  /// It's creating a variable called name that is set to a value when the object is created and can't
  /// be changed.
  final String name;

  /// It's creating a variable called id that is set to a value when the object is created and can't be
  /// changed.
  final String id;

  /// It's creating a variable called descr that is set to a value when the object is created and can't
  /// be changed.
  final String descr;

  /// It's creating a variable called value that is set to a value when the object is created and can't
  /// be changed.
  final double value;

  /// It's creating a variable called date that is set to a value when the object is created and can't
  /// be changed.
  final String date;

  /// It's creating a variable called category that is set to a value when the object is created and
  /// can't be changed.
  final ExpenseCategoryEnum category;

  /// It's a variable that is set to a value when the object is created and can't be changed.
  final String uid;

  /// It converts the object to a map.
  ///
  /// Returns:
  ///   A map of the data in the object.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'descr': descr,
      'value': value,
      'date': date,
      'category': category.name,
      'uid': uid,
    };
  }

  ExpenseItem copyWith({
    String? name,
    String? id,
    String? descr,
    double? value,
    String? date,
    ExpenseCategoryEnum? category,
    String? uid,
  }) {
    return ExpenseItem(
      name: name ?? this.name,
      id: id ?? this.id,
      descr: descr ?? this.descr,
      value: value ?? this.value,
      date: date ?? this.date,
      category: category ?? this.category,
      uid: uid ?? this.uid,
    );
  }
}

/// It's creating an enum that has two values: personal and house.
enum ExpenseCategoryEnum {
  /// It's a value of the enum ExpenseCategoryEnum.
  personal,

  /// It's a value of the enum ExpenseCategoryEnum.
  house,
}

/// It's a class that has a name property and an expenses property
class UserLists {
  /// It's a named constructor.
  UserLists({
    required this.name,
    required this.expenses,
  });

  /// It creates a UserLists object from a Map<String, dynamic> object.
  ///
  /// Args:
  ///   map (Map<String, dynamic>): The map of values to be inserted into the database.
  ///
  /// Returns:
  ///   A UserLists object with the name property set to the value of the name key in the map.
  // factory UserLists.fromMap(Map<String, dynamic> map) {
  //   return UserLists(
  //     name: map['name'] as String,
  //     expenses: List<ExpenseItem>.from(
  //       (map['expenses'] as List<int>).map<ExpenseItem>(
  //         (x) => ExpenseItem.fromMap(x as Map<String, dynamic>),
  //       ),
  //     ),
  //   );
  // }

  /// It's a variable that is set to a value when the object is created and can't be changed.
  final String name;

  final List<ExpenseItem> expenses;

  /// It returns a map of the object's properties.
  ///
  /// Returns:
  ///   A map of the name of the object and the value of the name property.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'expenses': expenses.map((x) => x.toMap()).toList(),
    };
  }
}
