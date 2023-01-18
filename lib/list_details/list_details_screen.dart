import 'dart:async';

import 'package:collection/collection.dart';
import 'package:cupertino_lists/cupertino_lists.dart';
import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:personal_expenses_tracker/auth/auth_service.dart';
import 'package:personal_expenses_tracker/list_details/expense_detail_screen.dart';
import 'package:personal_expenses_tracker/services/models.dart';
import 'package:personal_expenses_tracker/summary/summary_controller.dart';
import 'dart:ui' as ui;

/// `ListDetailsScreen` is a `StatelessWidget` that displays a list of expenses for a given list
class ListDetailsScreen extends StatefulWidget {
  /// A named constructor.
  const ListDetailsScreen({
    super.key,
    required this.userLists,
    required this.indexOfItem,
    required this.isGlobalList,
  });

  /// A required parameter that is passed in from the previous screen.
  final UserLists userLists;

  /// Creating a constructor for the class.
  final int indexOfItem;

  /// Declaring a variable called isGlobalList and assigning it a value of true.
  final bool isGlobalList;

  @override
  State<ListDetailsScreen> createState() => _ListDetailsScreenState();
}

class _ListDetailsScreenState extends State<ListDetailsScreen> {
  final expensesList = <String, List<ExpenseItem>>{};
  final originalMap = <String, List<ExpenseItem>>{};

  final Map<int, Widget> _options = {
    0: const Text('Hoy'),
    1: const Text('Semana'),
    2: const Text('Mes'),
  };
  int? _selectedOption = 0;

  bool filterEmpty = false;

  @override
  void initState() {
    expensesList.addAll(groupBy(widget.userLists.expenses, (p0) => p0.date));
    originalMap.addAll(expensesList);
    filterList(filter: 'today');
    initializeDateFormatting('es_MX');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: expensesList.isEmpty
          ? CustomScrollView(
              slivers: [
                CupertinoSliverNavigationBar(
                  largeTitle: Text(widget.userLists.name),
                  trailing: GestureDetector(
                    onTap: navigateToAddExpense,
                    behavior: HitTestBehavior.translucent,
                    child: const Icon(CupertinoIcons.add),
                  ),
                  backgroundColor: CupertinoColors.systemGroupedBackground,
                  border: null,
                  stretch: true,
                ),
                if (filterEmpty)
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: CupertinoSlidingSegmentedControl(
                            children: _options,
                            groupValue: _selectedOption,
                            onValueChanged: (int? value) {
                              _selectedOption = value;
                              var filter = 'today';
                              if (value == 1) {
                                filter = 'week';
                              } else if (value == 2) {
                                filter = 'month';
                              }
                              filterList(filter: filter);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                SliverFillRemaining(
                  child: WhatsNewPage(
                    title: Text(
                      filterEmpty ? 'Sin resultados' : 'Agregar gasto',
                    ),
                    features: [
                      if (!filterEmpty)
                        WhatsNewFeature(
                          icon: Icon(
                            CupertinoIcons.mail,
                            color:
                                CupertinoColors.systemBlue.resolveFrom(context),
                          ),
                          title: const Text('Ten el control'),
                          description: const Text(
                            'Lleva un control diario de todos los gastos que realizas en tu día a día.',
                          ),
                        ),
                      if (!filterEmpty)
                        WhatsNewFeature(
                          icon: Icon(
                            CupertinoIcons.eye,
                            color:
                                CupertinoColors.systemBlue.resolveFrom(context),
                          ),
                          title: const Text('Verifica'),
                          description: const Text(
                            'Puedes visualizar tus gastos por día, semana y mes',
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton.filled(
                          onPressed: navigateToAddExpense,
                          child: const Text('Agregar nuevo gasto'),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: CupertinoButton(
                          child: const Text('Atrás'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          : CustomScrollView(
              slivers: [
                CupertinoSliverNavigationBar(
                  largeTitle: Text(widget.userLists.name),
                  trailing: GestureDetector(
                    onTap: navigateToAddExpense,
                    behavior: HitTestBehavior.translucent,
                    child: const Icon(CupertinoIcons.add),
                  ),
                  backgroundColor: CupertinoColors.systemGroupedBackground,
                  border: null,
                  stretch: true,
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: CupertinoSlidingSegmentedControl(
                        children: _options,
                        groupValue: _selectedOption,
                        onValueChanged: (int? value) {
                          _selectedOption = value;
                          var filter = 'today';
                          if (value == 1) {
                            filter = 'week';
                          } else if (value == 2) {
                            filter = 'month';
                          }
                          filterList(filter: filter);
                        },
                      ),
                    )
                  ]),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: expensesList.length,
                    (context, index) {
                      final key = expensesList.keys.elementAt(index);
                      final value = expensesList[key]!;
                      // ignore: omit_local_variable_types
                      final double total = value.fold(
                        0,
                        (previous, current) => previous + current.value,
                      );

                      return SafeArea(
                        top: false,
                        bottom: index == expensesList.length - 1,
                        child: CupertinoListSection.insetGrouped(
                          header: Text(
                            DateFormat.yMMMd('es_MX')
                                .format(DateTime.parse(key)),
                          ),
                          hasLeading: false,
                          footer: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                NumberFormat.currency(
                                  locale: 'es_MX',
                                  symbol: r'$',
                                ).format(total),
                              ),
                            ],
                          ),
                          children: List.generate(value.length, (index2) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute<void>(
                                    builder: (context) => ExpenseDetailScreen(
                                      index: index2,
                                      expenseItem: value[index2],
                                      expenseId: value[index2].id,
                                      listName: widget.userLists.name,
                                      isGlobalItem: widget.isGlobalList,
                                    ),
                                  ),
                                );
                              },
                              behavior: HitTestBehavior.translucent,
                              child: CupertinoListTile.notched(
                                title: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 220),
                                  child: Text(
                                    capitalizeFirstLetter(value[index2].name),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                subtitle: Text(
                                  capitalizeFirstLetter(
                                    value[index2].category.name,
                                  ),
                                ),
                                trailing: Text(
                                  NumberFormat.currency(
                                    locale: 'es_MX',
                                    symbol: r'$',
                                  ).format(value[index2].value),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void filterList({required String filter}) {
    final dateTime = DateTime.now();
    final todayDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final week = todayDay.weekOfMonth;
    final month = todayDay.month;
    final year = todayDay.year;

    final filteredList = <String, List<ExpenseItem>>{};

    for (final key in originalMap.keys) {
      if (filter == 'today') {
        if (DateTime.parse(key) == todayDay) {
          filteredList[key] = originalMap[key]!;
        }
      } else if (filter == 'week') {
        if (DateTime.parse(key).weekOfMonth == week &&
            DateTime.parse(key).year == year) {
          filteredList[key] = originalMap[key]!;
        }
      } else if (filter == 'month') {
        if (DateTime.parse(key).month == month) {
          filteredList[key] = originalMap[key]!;
        }
      }
    }

    if (filteredList.isEmpty) {
      filterEmpty = true;
    }

    if (widget.userLists.expenses.isEmpty) {
      filterEmpty = false;
    }

    setState(() {
      expensesList
        ..clear()
        ..addAll(filteredList);
    });
  }

  void navigateToAddExpense() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();
    final valueController = TextEditingController();
    final categoryController = TextEditingController();

    showCupertinoModalBottomSheet<void>(
      context: context,
      backgroundColor: CupertinoColors.systemGroupedBackground,
      builder: (modalContext) {
        return CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text(
                'Agregar gasto',
                style: TextStyle(fontSize: 20),
              ),
              backgroundColor: CupertinoColors.systemGroupedBackground,
              border: null,
              leading: GestureDetector(
                onTap: () {
                  Navigator.pop(modalContext);
                },
                child: const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: Text(
                    'Atrás',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.activeBlue,
                    ),
                  ),
                ),
              ),
              trailing: Consumer(
                builder: (consumerContext, ref, child) {
                  return GestureDetector(
                    onTap: () async {
                      final value = double.parse(
                        valueController.text
                            .replaceAll(r'$', '')
                            .replaceAll('.', '')
                            .replaceAll(',', ''),
                      );

                      final uid = await _getUid();

                      ExpenseCategoryEnum category;

                      if (categoryController.text == 'personal') {
                        category = ExpenseCategoryEnum.personal;
                      } else {
                        category = ExpenseCategoryEnum.house;
                      }

                      var expenseItem = ExpenseItem(
                        name: nameController.text.trim(),
                        descr: descriptionController.text.trim(),
                        value: value,
                        id: '',
                        date: dateController.text,
                        category: category,
                        uid: uid,
                      );

                      modalContext.loaderOverlay.show();
                      final result = await ref
                          .read(summaryControllerProvider.notifier)
                          .addNewExpense(
                            expenseItem: expenseItem,
                            isGlobal: widget.isGlobalList,
                            listName: widget.userLists.name,
                          );

                      if (result.ok && mounted) {
                        final summaryProvider =
                            ref.read(summaryControllerProvider);

                        expenseItem = expenseItem.copyWith(
                          value: expenseItem.value / 100,
                        );

                        if (widget.isGlobalList) {
                          summaryProvider
                              .globalList.value![widget.indexOfItem].expenses
                              .add(expenseItem);
                        } else {
                          summaryProvider
                              .list.value![widget.indexOfItem].expenses
                              .add(expenseItem);
                        }

                        expensesList[dateController.text]!.add(expenseItem);
                        Navigator.pop(modalContext);
                      } else {
                        unawaited(
                          showDialogSuccess(
                            title: 'Error',
                            message: result.message,
                          ),
                        );
                      }

                      modalContext.loaderOverlay.hide();
                    },
                    child: const Text(
                      'Listo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  );
                },
              ),
              stretch: true,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  CupertinoListSection.insetGrouped(
                    hasLeading: false,
                    children: [
                      CupertinoTextFormFieldRow(
                        prefix: const Text('Nombre'),
                        placeholder: 'nombre',
                        controller: nameController,
                        textAlign: TextAlign.right,
                      ),
                      CupertinoTextFormFieldRow(
                        prefix: const Text('Descripción'),
                        placeholder: 'descripción',
                        controller: descriptionController,
                        textAlign: TextAlign.right,
                      ),
                      CupertinoTextFormFieldRow(
                        readOnly: true,
                        onTap: () {
                          showCupertinoModalPopup<void>(
                            context: context,
                            builder: (modalContext) => ColoredBox(
                              color: CupertinoColors.systemGroupedBackground,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Wrap(
                                  children: [
                                    SizedBox(
                                      height: 80,
                                      child: CupertinoPicker(
                                        itemExtent: 32,
                                        scrollController:
                                            FixedExtentScrollController(),
                                        onSelectedItemChanged: (v) {
                                          debugPrint(v.toString());
                                          if (v == 0) {
                                            categoryController.text =
                                                'personal';
                                          } else {
                                            categoryController.text = 'house';
                                          }
                                        },
                                        children: const [
                                          Text('Personal'),
                                          Text('House'),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: CupertinoButton(
                                        child: const Text('Seleccionar'),
                                        onPressed: () {
                                          categoryController.text = 'personal';
                                          Navigator.of(modalContext).pop();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        controller: categoryController,
                        prefix: const Text('Categoría'),
                        placeholder: 'selecciona una categoría',
                        textAlign: TextAlign.right,
                      ),
                      CupertinoTextFormFieldRow(
                        readOnly: true,
                        onTap: () {
                          showCupertinoModalPopup<void>(
                            context: context,
                            builder: (modalContext) => ColoredBox(
                              color: CupertinoColors.systemGroupedBackground,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Wrap(
                                  children: [
                                    SizedBox(
                                      height: 80,
                                      child: CupertinoDatePicker(
                                        initialDateTime: DateTime.now(),
                                        mode: CupertinoDatePickerMode.date,
                                        dateOrder: DatePickerDateOrder.dmy,
                                        onDateTimeChanged: (val) {
                                          dateController.text =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(val);
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: CupertinoButton(
                                        child: const Text('Seleccionar'),
                                        onPressed: () {
                                          dateController.text =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(DateTime.now());
                                          Navigator.of(modalContext).pop();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        controller: dateController,
                        prefix: const Text('Fecha'),
                        placeholder: 'selecciona una fecha',
                        textAlign: TextAlign.right,
                      ),
                      CupertinoTextFormFieldRow(
                        controller: valueController,
                        prefix: const Text('Monto'),
                        inputFormatters: [
                          CurrencyTextInputFormatter(
                            locale: 'es_MX',
                            symbol: r'$',
                          )
                        ],
                        keyboardType: TextInputType.number,
                        placeholder: r'$20.00',
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String capitalizeFirstLetter(String s) {
    if (s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
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

  Future<void> showDialogSuccess({
    required String message,
    required String title,
  }) async {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(title),
          ),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Listo'),
            ),
          ],
        );
      },
    );
  }
}

/// An extension method that returns the week of the month.
extension DateTimeExtension on DateTime {
  /// An extension method that returns the week of the month.
  int get weekOfMonth {
    final date = this;
    final firstDayOfTheMonth = DateTime(date.year, date.month);
    final sum = firstDayOfTheMonth.weekday - 1 + date.day;
    if (sum % 7 == 0) {
      return sum ~/ 7;
    } else {
      return sum ~/ 7 + 1;
    }
  }
}
