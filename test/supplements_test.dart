import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';
import 'components_test.dart' show host;

void main() {
  testWidgets(
    'integer stepper commits bounds, restores Escape and steps with arrows',
    (tester) async {
      var value = 13;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => IanvsNumberStepper(
              label: '字号',
              value: value,
              min: 8,
              max: 32,
              onChanged: (next) => setState(() => value = next),
            ),
          ),
        ),
      );
      await tester.tap(find.byTooltip('增加 字号'));
      await tester.pump();
      expect(value, 14);
      await tester.enterText(find.byType(TextField), '999');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(value, 32);
      expect(
        tester
            .widget<IconButton>(
              find.descendant(
                of: find.byTooltip('增加 字号'),
                matching: find.byType(IconButton),
              ),
            )
            .onPressed,
        isNull,
      );
      await tester.enterText(find.byType(TextField), '19');
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '32',
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(value, 31);
      await tester.enterText(find.byType(TextField), '-');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '31',
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('stepper respects rejected requests and disabled state', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(IanvsNumberStepper(label: 'Count', value: 8, onChanged: (_) {})),
    );
    await tester.enterText(find.byType(TextField), '19');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '8',
    );
    await tester.pumpWidget(
      host(const IanvsNumberStepper(label: 'Count', value: 8)),
    );
    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  const options = [
    IanvsCascadeOption(
      value: 'local',
      label: 'Local',
      children: [
        IanvsCascadeOption(
          value: 'shell',
          label: 'Shell',
          children: [
            IanvsCascadeOption(value: 'login', label: 'Login'),
            IanvsCascadeOption(
              value: 'blocked',
              label: 'Blocked',
              enabled: false,
            ),
          ],
        ),
      ],
    ),
    IanvsCascadeOption(
      value: 'remote',
      label: 'Remote',
      children: [IanvsCascadeOption(value: 'ssh', label: 'SSH')],
    ),
  ];
  testWidgets(
    'cascader backtracking preserves value and a new parent drops descendants',
    (tester) async {
      List<String> path = ['local', 'shell', 'login'];
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) => IanvsCascader<String>(
              options: options,
              value: path,
              onChanged: (next) => setState(() => path = next),
            ),
          ),
        ),
      );
      expect(find.text('Login'), findsOneWidget);
      await tester.tap(find.text('Blocked'));
      expect(path, ['local', 'shell', 'login']);
      await tester.tap(find.text('全部'));
      await tester.pump();
      expect(path, ['local', 'shell', 'login']);
      await tester.tap(find.text('Remote'));
      await tester.pump();
      expect(path, ['remote']);
      expect(find.text('SSH'), findsOneWidget);
      await tester.tap(find.text('SSH'));
      await tester.pump();
      expect(path, ['remote', 'ssh']);
      expect(() => path.add('x'), throwsUnsupportedError);
    },
  );
  testWidgets('cascader only advances after a parent accepts the path', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        IanvsCascader<String>(
          options: options,
          value: const [],
          onChanged: (_) {},
        ),
      ),
    );
    await tester.tap(find.text('Local'));
    await tester.pump();
    expect(find.text('Shell'), findsNothing);
    await tester.pumpWidget(
      host(
        IanvsCascader<String>(
          options: options,
          value: const ['remote'],
          onChanged: (_) {},
        ),
      ),
    );
    expect(find.text('SSH'), findsOneWidget);
  });
  testWidgets(
    'skeleton delays paint, retains layout and hides loading child semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var loading = true;
      late StateSetter update;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: IanvsSkeleton(
                  loading: loading,
                  child: const SizedBox(
                    width: 300,
                    height: 144,
                    child: Text('Loaded content'),
                  ),
                ),
              );
            },
          ),
        ),
      );
      final before = tester.getSize(find.byType(IanvsSkeleton));
      final pulse = find.descendant(
        of: find.byType(IanvsSkeleton),
        matching: find.byType(FadeTransition),
      );
      expect(pulse, findsNothing);
      expect(find.bySemanticsLabel('Loaded content'), findsNothing);
      expect(find.bySemanticsLabel('正在加载'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 250));
      expect(tester.widget<FadeTransition>(pulse).opacity.value, 1);
      expect(tester.hasRunningAnimations, isFalse);
      update(() => loading = false);
      await tester.pump();
      expect(tester.getSize(find.byType(IanvsSkeleton)), before);
      expect(find.bySemanticsLabel('Loaded content'), findsOneWidget);
      semantics.dispose();
    },
  );
  for (final brightness in Brightness.values) {
    testWidgets('supplement controls fit 200% text $brightness', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        host(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IanvsCascader<String>(
                options: options,
                value: const ['local'],
                onChanged: (_) {},
              ),
              IanvsNumberStepper(label: 'Number', value: 13, onChanged: (_) {}),
            ],
          ),
          brightness: brightness,
          density: IanvsDensity.touch,
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
