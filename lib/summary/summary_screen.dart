import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:personal_expenses_tracker/list_details/list_details_screen.dart';
import 'package:personal_expenses_tracker/summary/summary_controller.dart';

/// It's a CupertinoPageScaffold with a SafeArea containing a CupertinoListSection.insetGrouped with a
/// header and three children
class SummaryScreen extends ConsumerStatefulWidget {
  /// It's a constructor.
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  late int pressTime = 0;
  final Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(summaryControllerProvider.notifier).loadLists();
      await ref.read(summaryControllerProvider.notifier).loadGlobalLists();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final lists = ref.watch(summaryControllerProvider).list;
    final globalLists = ref.watch(summaryControllerProvider).globalList;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            CupertinoSliverNavigationBar(
              largeTitle: const Text('Resumen'),
              backgroundColor: CupertinoColors.systemGroupedBackground,
              border: null,
              trailing: GestureDetector(
                onTap: showDialogWithTextField,
                behavior: HitTestBehavior.translucent,
                child: const Icon(CupertinoIcons.add),
              ),
            ),
            CupertinoSliverRefreshControl(
              onRefresh: () async {
                await ref.read(summaryControllerProvider.notifier).loadLists();
                await ref
                    .read(summaryControllerProvider.notifier)
                    .loadGlobalLists();
              },
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                globalLists.when(
                  data: (data) {
                    if (data.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 40,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Aún no tienes listas globales agregadas, empezemos agregando una',
                              style: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .merge(
                                    TextStyle(
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? CupertinoColors.white
                                          : CupertinoColors.secondaryLabel,
                                      fontSize: 15,
                                      height: 1.3,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 30),
                            CupertinoButton.filled(
                              onPressed: showDialogWithTextField,
                              child: const Text('Agregar Lista'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return CupertinoListSection.insetGrouped(
                        header: const Text('Listas globales'),
                        hasLeading: false,
                        children: List.generate(data.length, (index) {
                          return Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction) async {
                              final result = await ref
                                  .read(summaryControllerProvider.notifier)
                                  .deleteList(
                                    listName: data[index].name,
                                    isGlobal: true,
                                  );

                              if (result.ok) {
                                await ref
                                    .read(summaryControllerProvider.notifier)
                                    .loadGlobalLists();
                              }
                            },
                            confirmDismiss: (direction) {
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
                                            Text(
                                              'Se eliminarán todos los gasto dentro de la lista y nadie más podrá verla',
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Esta acción es irreversible',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: CupertinoColors
                                                    .destructiveRed,
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            onPressed: () {
                                              Navigator.of(modalContext)
                                                  .pop(false);
                                            },
                                            child: const Text('Cancelar'),
                                          ),
                                          CupertinoDialogAction(
                                            isDefaultAction: true,
                                            onPressed: () {
                                              Navigator.of(modalContext)
                                                  .pop(true);
                                            },
                                            child: const Text('Vamos'),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            background: ColoredBox(
                              color: CupertinoColors.destructiveRed,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    CupertinoIcons.delete,
                                    color: CupertinoColors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Eliminar',
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute<void>(
                                    builder: (context) => ListDetailsScreen(
                                      indexOfItem: index,
                                      isGlobalList: true,
                                      userLists: data[index],
                                    ),
                                  ),
                                );
                              },
                              child: CupertinoListTile.notched(
                                title: Text(data[index].name),
                                trailing: const CupertinoListTileChevron(),
                              ),
                            ),
                          );
                        }),
                      );
                    }
                  },
                  error: (error, stackTrace) => const Text(
                    'Hubo un problema, intenta de nuevo más tarde',
                  ),
                  loading: CupertinoActivityIndicator.new,
                ),
              ]),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                lists.when(
                  data: (data) {
                    if (data.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 40,
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Aún no tienes listas agregadas, empezemos agregando una',
                              style: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .merge(
                                    TextStyle(
                                      color: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? CupertinoColors.white
                                          : CupertinoColors.secondaryLabel,
                                      fontSize: 15,
                                      height: 1.3,
                                      letterSpacing: -0.1,
                                    ),
                                  ),
                            ),
                            const SizedBox(height: 30),
                            CupertinoButton.filled(
                              onPressed: showDialogWithTextField,
                              child: const Text('Agregar Lista'),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return CupertinoListSection.insetGrouped(
                        header: const Text('Mis Listas'),
                        hasLeading: false,
                        children: List.generate(data.length, (index) {
                          return Dismissible(
                            key: UniqueKey(),
                            onDismissed: (direction) async {
                              final result = await ref
                                  .read(summaryControllerProvider.notifier)
                                  .deleteList(
                                    listName: data[index].name,
                                    isGlobal: false,
                                  );

                              if (result.ok) {
                                await ref
                                    .read(summaryControllerProvider.notifier)
                                    .loadLists();
                              }
                            },
                            confirmDismiss: (direction) {
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
                                            Text(
                                              'Se eliminarán todos los gasto dentro de la lista',
                                            ),
                                            SizedBox(height: 10),
                                            Text(
                                              'Esta acción es irreversible',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: CupertinoColors
                                                    .destructiveRed,
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            onPressed: () {
                                              Navigator.of(modalContext)
                                                  .pop(false);
                                            },
                                            child: const Text('Cancelar'),
                                          ),
                                          CupertinoDialogAction(
                                            isDefaultAction: true,
                                            onPressed: () {
                                              Navigator.of(modalContext)
                                                  .pop(true);
                                            },
                                            child: const Text('Vamos'),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            background: ColoredBox(
                              color: CupertinoColors.destructiveRed,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    CupertinoIcons.delete,
                                    color: CupertinoColors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Eliminar',
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute<void>(
                                    builder: (context) => ListDetailsScreen(
                                      indexOfItem: index,
                                      isGlobalList: false,
                                      userLists: data[index],
                                    ),
                                  ),
                                );
                              },
                              child: CupertinoListTile.notched(
                                title: Text(data[index].name),
                                trailing: const CupertinoListTileChevron(),
                              ),
                            ),
                          );
                        }),
                      );
                    }
                  },
                  error: (error, stackTrace) => const Text(
                    'Hubo un problema, intenta de nuevo más tarde',
                  ),
                  loading: CupertinoActivityIndicator.new,
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showDialogWithTextField() async {
    final controller = TextEditingController();
    var isGlobal = false;
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return CupertinoAlertDialog(
              title: const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text('Nueva lista'),
              ),
              content: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Lista global'),
                      CupertinoSwitch(
                        value: isGlobal,
                        activeColor: CupertinoColors.activeBlue,
                        onChanged: (bool? value) {
                          setState(() {
                            isGlobal = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: controller,
                    cursorColor: CupertinoColors.activeBlue,
                    placeholder: 'Nombra tu nueva lista',
                  ),
                ],
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () async {
                    Navigator.pop(context);
                    context.loaderOverlay.show();
                    final result = await ref
                        .read(summaryControllerProvider.notifier)
                        .addNewList(id: controller.text, isGlobal: isGlobal);

                    if (result.ok && mounted) {
                      await ref
                          .read(summaryControllerProvider.notifier)
                          .loadLists();
                      await ref
                          .read(summaryControllerProvider.notifier)
                          .loadGlobalLists();
                      context.loaderOverlay.hide();
                    } else {
                      context.loaderOverlay.hide();
                    }
                  },
                  child: const Text('Agregar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showDialogSuccess({required String message}) async {
    return showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text('Nueva lista'),
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

  void showLoadingDialog() {
    showCupertinoDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Cargando'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CupertinoActivityIndicator(),
              SizedBox(height: 20),
              Text('Espera un momento...'),
            ],
          ),
        );
      },
    );
  }
}
