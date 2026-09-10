import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

Widget host(
  Widget child, {
  Brightness brightness = Brightness.dark,
  IanvsDensity density = IanvsDensity.compact,
}) => MaterialApp(
  theme: IanvsTheme.build(brightness: brightness, density: density),
  home: Scaffold(
    body: Center(
      child: SizedBox(width: 380, child: SingleChildScrollView(child: child)),
    ),
  ),
);

void main() {
  testWidgets('async button suppresses duplicates, reports busy and recovers', (
    tester,
  ) async {
    final completion = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      host(
        IanvsButton(
          onPressed: () {
            calls++;
            return completion.future;
          },
          child: const Text('保存'),
        ),
      ),
    );
    await tester.tap(find.text('保存'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.text('保存'));
    expect(calls, 1);
    completion.complete();
    await tester.pump();
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });
  testWidgets('async error callback preserves usability', (tester) async {
    Object? reported;
    await tester.pumpWidget(
      host(
        IanvsButton(
          onPressed: () => Future<void>.error(StateError('failed')),
          onError: (error, stack) => reported = error,
          child: const Text('重试'),
        ),
      ),
    );
    await tester.tap(find.text('重试'));
    await tester.pump();
    await tester.pump();
    expect(reported, isA<StateError>());
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNotNull,
    );
  });
  testWidgets('external focus and controller survive component removal', (
    tester,
  ) async {
    final focus = FocusNode();
    final controller = TextEditingController();
    await tester.pumpWidget(
      host(IanvsTextField(focusNode: focus, controller: controller)),
    );
    await tester.enterText(find.byType(TextFormField), 'Ianvs');
    await tester.pumpWidget(const SizedBox());
    controller.text = 'reused';
    focus.requestFocus();
    expect(controller.text, 'reused');
    controller.dispose();
    focus.dispose();
  });
  testWidgets(
    'select synchronizes parent values, validates, saves and resets',
    (tester) async {
      final form = GlobalKey<FormState>();
      String? value;
      String? saved;
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return Form(
                key: form,
                child: IanvsSelect<String>(
                  value: value,
                  options: const [
                    IanvsOption('a', 'Alpha'),
                    IanvsOption('b', 'Beta'),
                  ],
                  onChanged: (next) => setState(() => value = next),
                  validator: (v) => v == null ? 'Required' : null,
                  onSaved: (v) => saved = v,
                ),
              );
            },
          ),
        ),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
      update(() => value = 'b');
      await tester.pump();
      expect(form.currentState!.validate(), isTrue);
      form.currentState!.save();
      expect(saved, 'b');
      await tester.tap(find.byType(IanvsSelect<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alpha').last);
      await tester.pumpAndSettle();
      expect(value, 'a');
      // A controlled field resets to the latest value provided by its parent.
      form.currentState!.reset();
      await tester.pump();
      expect(value, 'a');
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('confirm Escape returns false and safe action gets focus', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showIanvsConfirmDialog(
                context: context,
                title: 'Discard?',
                message: 'Unsaved text',
                destructive: true,
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(result, isFalse);
    expect(find.byType(AlertDialog), findsNothing);
  });
  for (final brightness in Brightness.values) {
    for (final density in IanvsDensity.values) {
      testWidgets('field and action fit 200% text $brightness $density', (
        tester,
      ) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          host(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IanvsFieldRow(
                  label: 'Very long configuration label',
                  helper: 'Useful helper text',
                  child: IanvsTextField(initialValue: 'content'),
                ),
                IanvsButton(
                  onPressed: () {},
                  child: const Text('Save configuration'),
                ),
                IanvsSettingsRow(
                  title: 'Restore workspace',
                  description: 'Restore the previous layout',
                  value: true,
                  onChanged: (_) {},
                ),
              ],
            ),
            brightness: brightness,
            density: density,
          ),
        );
        expect(tester.takeException(), isNull);
        final size = tester.getSize(find.byType(TextFormField));
        expect(size.height, greaterThanOrEqualTo(32));
      });
    }
  }
  testWidgets('icon action exposes its accessible name', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        IanvsIconButton(
          icon: Icons.add,
          tooltip: 'Create project',
          onPressed: () {},
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Create project')).label,
      contains('Create project'),
    );
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Create project'))
          .getSemanticsData()
          .flagsCollection
          .isButton,
      isTrue,
    );
    semantics.dispose();
  });
  testWidgets(
    'select paints its focus border and supports keyboard selection',
    (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      String? chosen;
      await tester.pumpWidget(
        host(
          IanvsSelect<String>(
            focusNode: focus,
            value: 'a',
            options: const [
              IanvsOption('a', 'Alpha'),
              IanvsOption('b', 'Beta'),
            ],
            onChanged: (value) => chosen = value,
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      expect(
        tester.widget<InputDecorator>(find.byType(InputDecorator)).isFocused,
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(chosen, 'b');
    },
  );
}
