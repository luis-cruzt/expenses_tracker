import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:personal_expenses_tracker/services/models.dart';
import 'package:personal_expenses_tracker/summary/summary_controller.dart';

/// `ExpenseDetailScreen` is a `StatelessWidget` that displays a `CupertinoPageScaffold` with a
/// `CupertinoListSection.insetGrouped` that contains a `CupertinoListTile.notched` with a `title`
class ExpenseDetailScreen extends StatefulWidget {
  /// A constructor that takes in a `key` and `expenseItem` as parameters.
  const ExpenseDetailScreen({
    super.key,
    required this.index,
    required this.listName,
    required this.expenseId,
    required this.isGlobalItem,
    required this.expenseItem,
  });

  /// A `final` variable that is a `ExpenseItem` type.
  final ExpenseItem expenseItem;

  /// The id of the expense that is being displayed.
  final String expenseId;

  /// The index of the expense in the list.
  final int index;

  /// A variable that is used to determine if the expense is a global expense or not.
  final bool isGlobalItem;

  /// The name of the list that the expense is in.
  final String listName;

  @override
  State<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends State<ExpenseDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text(
                'Información detallada',
                style: TextStyle(fontSize: 20),
              ),
              trailing: GestureDetector(
                onTap: () {
                  _showQuestion(context);
                },
                child: const Icon(
                  CupertinoIcons.delete,
                  size: 22,
                  color: CupertinoColors.destructiveRed,
                ),
              ),
              backgroundColor: CupertinoColors.systemGroupedBackground,
              border: null,
              stretch: true,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        _DescriptionWidget(
                          label: 'Nombre',
                          value: widget.expenseItem.name,
                        ),
                        const _Divider(),
                        _DescriptionWidget(
                          label: 'Descripción',
                          value: widget.expenseItem.descr,
                        ),
                        const _Divider(),
                        _DescriptionWidget(
                          label: 'Categoría',
                          value: widget.expenseItem.category.name,
                        ),
                        const _Divider(),
                        _DescriptionWidget(
                          label: 'Fecha del gasto',
                          value: DateFormat.MMMMEEEEd('es_MX')
                              .format(DateTime.parse(widget.expenseItem.date)),
                        ),
                        const _Divider(),
                        _DescriptionWidget(
                          label: 'Categoría',
                          value: widget.expenseItem.category.name,
                        ),
                        const _Divider(),
                        _DescriptionWidget(
                          label: 'Total',
                          value: NumberFormat.currency(
                            locale: 'es_MX',
                            symbol: r'$',
                          ).format(widget.expenseItem.value),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuestion(BuildContext context) {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (modalContext, setState) {
            return CupertinoAlertDialog(
              title: const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text('¿Estás seguro?'),
              ),
              content: Column(
                children: const [
                  Text('¿Estás seguro de eliminar este gasto?'),
                  SizedBox(height: 10),
                  Text(
                    'Esta acción es irreversible',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.destructiveRed,
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  onPressed: () {
                    Navigator.of(modalContext).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    return CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () async {
                        modalContext.loaderOverlay.show();
                        final result = await ref
                            .read(summaryControllerProvider.notifier)
                            .deleteExpense(
                              id: widget.expenseId,
                              listName: widget.listName,
                            );

                        modalContext.loaderOverlay.hide();

                        if (result.ok && mounted) {
                          final summaryProvider =
                              ref.read(summaryControllerProvider);
                          if (widget.isGlobalItem) {
                            summaryProvider.globalList.value!
                                .removeAt(widget.index);
                          } else {
                            summaryProvider.list.value!.removeAt(widget.index);
                          }

                          Navigator.pop(modalContext);
                          Navigator.pop(context);
                        } else {
                          unawaited(
                            _showDialogSuccess(
                              title: 'Error',
                              context: modalContext,
                              message: result.message,
                            ),
                          );
                        }
                      },
                      child: const Text('Vamos'),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDialogSuccess({
    required String title,
    required String message,
    required BuildContext context,
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

class _DescriptionWidget extends StatelessWidget {
  const _DescriptionWidget({
    required this.label,
    required this.value,
  });

  final String label;

  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: CupertinoTheme.of(context).textTheme.textStyle.merge(
                  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: CupertinoTheme.of(context).textTheme.textStyle.merge(
                  TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                ),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CupertinoColors.separator,
      margin: const EdgeInsets.symmetric(vertical: 8),
      height: 1.0 / MediaQuery.of(context).devicePixelRatio,
    );
  }
}
