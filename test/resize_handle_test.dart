import 'dart:ui' show PointerDeviceKind, SemanticsAction;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

void main() {
  group('macOS pointer and keyboard focus feedback', () {
    for (final axis in Axis.values) {
      for (final reverse in [false, true]) {
        for (final cancel in [false, true]) {
          testWidgets(
            'mouse drag $axis reverse=$reverse cancel=$cancel clears highlight',
            (tester) async {
              var value = 260.0;
              final focus = FocusNode();
              addTearDown(focus.dispose);
              final theme = reverse ? IanvsTheme.dark() : IanvsTheme.light();
              final tokens = theme.extension<IanvsTokens>()!;
              await tester.pumpWidget(
                MaterialApp(
                  theme: theme,
                  home: Scaffold(
                    body: StatefulBuilder(
                      builder: (context, setState) => Flex(
                        direction: axis,
                        children: [
                          IanvsResizeHandle(
                            value: value,
                            min: 100,
                            max: 400,
                            axis: axis,
                            reverse: reverse,
                            focusNode: focus,
                            semanticLabel: 'Panel size',
                            onChanged: (next) => setState(() => value = next),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
              final handle = find.byType(IanvsResizeHandle);
              final line = find.descendant(
                of: handle,
                matching: find.byType(ColoredBox),
              );
              double thickness() => axis == Axis.horizontal
                  ? tester.getSize(line).width
                  : tester.getSize(line).height;
              Color color() => tester.widget<ColoredBox>(line).color;

              // Keep the default desktop strategy: mouse events do not switch
              // Flutter's traditional focus highlights off on macOS.
              expect(
                FocusManager.instance.highlightStrategy,
                FocusHighlightStrategy.automatic,
              );
              await tester.sendKeyEvent(LogicalKeyboardKey.tab);
              await tester.pump();
              expect(focus.hasFocus, isTrue);
              expect(color(), tokens.focus);
              expect(thickness(), 2);

              final mouse = await tester.createGesture(
                kind: PointerDeviceKind.mouse,
              );
              await mouse.addPointer(location: tester.getCenter(handle));
              await mouse.down(tester.getCenter(handle));
              final delta = axis == Axis.horizontal
                  ? const Offset(24, 0)
                  : const Offset(0, 24);
              await mouse.moveBy(delta);
              await mouse.moveBy(delta);
              await tester.pump();
              expect(value, reverse ? lessThan(260) : greaterThan(260));
              expect(color(), tokens.focus);
              expect(thickness(), 2);
              if (cancel) {
                await mouse.cancel();
              } else {
                await mouse.up();
              }
              await tester.pump();
              expect(focus.hasFocus, isTrue);
              expect(
                FocusManager.instance.highlightMode,
                FocusHighlightMode.traditional,
              );
              expect(color(), isNot(tokens.focus));
              expect(thickness(), 1);

              await mouse.moveTo(tester.getCenter(handle));
              await tester.pump();
              expect(color(), tokens.border);
              expect(thickness(), 1);
              await mouse.moveTo(const Offset(700, 500));
              await tester.pump();
              expect(color(), tokens.separator);
              expect(thickness(), 1);

              final previous = value;
              await tester.sendKeyEvent(
                axis == Axis.horizontal
                    ? LogicalKeyboardKey.arrowRight
                    : LogicalKeyboardKey.arrowDown,
              );
              await tester.pump();
              expect(value, previous + (reverse ? -20 : 20));
              expect(color(), tokens.focus);
              expect(thickness(), 2);
              await mouse.removePointer();
            },
            variant: TargetPlatformVariant.only(TargetPlatform.macOS),
          );
        }
      }
    }

    testWidgets(
      'mouse click and double-click reset keep focus without blue',
      (tester) async {
        var value = 300.0;
        final focus = FocusNode();
        addTearDown(focus.dispose);
        final theme = IanvsTheme.light();
        final tokens = theme.extension<IanvsTokens>()!;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) => Row(
                  children: [
                    IanvsResizeHandle(
                      value: value,
                      min: 220,
                      max: 320,
                      resetValue: 260,
                      focusNode: focus,
                      semanticLabel: 'Panel size',
                      onChanged: (next) => setState(() => value = next),
                    ),
                    const Focus(child: SizedBox(width: 20, height: 20)),
                  ],
                ),
              ),
            ),
          ),
        );
        final handle = find.byType(IanvsResizeHandle);
        final line = find.descendant(
          of: handle,
          matching: find.byType(ColoredBox),
        );
        void expectNeutral() {
          expect(focus.hasFocus, isTrue);
          expect(tester.widget<ColoredBox>(line).color, isNot(tokens.focus));
          expect(tester.getSize(line).width, 1);
        }

        await tester.tap(handle, kind: PointerDeviceKind.mouse);
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();
        expectNeutral();
        expect(value, 300);
        // Traversal away and back must restore keyboard-visible focus.
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        expect(focus.hasFocus, isFalse);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pump();
        expect(focus.hasFocus, isTrue);
        expect(tester.widget<ColoredBox>(line).color, tokens.focus);
        expect(tester.getSize(line).width, 2);

        await tester.tap(handle, kind: PointerDeviceKind.mouse);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(handle, kind: PointerDeviceKind.mouse);
        await tester.pumpAndSettle();
        expect(value, 260);
        expectNeutral();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pump();
        expect(value, 280);
        expect(tester.widget<ColoredBox>(line).color, tokens.focus);
        expect(tester.getSize(line).width, 2);
      },
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    );
  });

  for (final axis in Axis.values) {
    for (final reverse in [false, true]) {
      testWidgets(
        'drag clamps and changes panel extent $axis reverse=$reverse',
        (tester) async {
          var value = 260.0;
          await tester.pumpWidget(
            MaterialApp(
              theme: IanvsTheme.light(),
              home: Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    final children = [
                      SizedBox(
                        key: const Key('panel'),
                        width: axis == Axis.horizontal ? value : null,
                        height: axis == Axis.vertical ? value : null,
                      ),
                      IanvsResizeHandle(
                        value: value,
                        min: 220,
                        max: 320,
                        axis: axis,
                        reverse: reverse,
                        semanticLabel: 'Panel size',
                        onChanged: (next) => setState(() => value = next),
                      ),
                      const Expanded(child: SizedBox()),
                    ];
                    return Flex(direction: axis, children: children);
                  },
                ),
              ),
            ),
          );
          final sign = reverse ? -1.0 : 1.0;
          final handle = find.byType(IanvsResizeHandle);
          await tester.drag(
            handle,
            axis == Axis.horizontal
                ? Offset(150 * sign, 0)
                : Offset(0, 150 * sign),
          );
          await tester.pump();
          expect(value, 320);
          final size = tester.getSize(find.byKey(const Key('panel')));
          expect(axis == Axis.horizontal ? size.width : size.height, 320);
          await tester.drag(
            handle,
            axis == Axis.horizontal
                ? Offset(-180 * sign, 0)
                : Offset(0, -180 * sign),
          );
          await tester.pump();
          expect(value, 220);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets(
    'keyboard, semantics, reset and external focus share controlled values',
    (tester) async {
      var value = 260.0;
      final focus = FocusNode();
      addTearDown(focus.dispose);
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => Row(
                children: [
                  IanvsResizeHandle(
                    value: value,
                    min: 220,
                    max: 320,
                    resetValue: 260,
                    reverse: true,
                    focusNode: focus,
                    semanticLabel: 'Inspector width',
                    semanticValueFormatter: (value) =>
                        '${value.round()} points',
                    onChanged: (next) => setState(() => value = next),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(value, 280);
      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pump();
      expect(value, 220);
      var node = tester.getSemantics(find.byType(IanvsResizeHandle));
      expect(node.getSemanticsData().value, '220 points');
      expect(
        node.getSemanticsData().hasAction(SemanticsAction.decrease),
        isFalse,
      );
      node.owner!.performAction(node.id, SemanticsAction.increase);
      await tester.pump();
      expect(value, 240);
      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pump();
      expect(value, 320);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(value, 260);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      final handle = find.byType(IanvsResizeHandle);
      await tester.tap(handle);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(handle);
      await tester.pumpAndSettle();
      expect(value, 260);
      await tester.pumpWidget(const SizedBox());
      // Caller-owned nodes remain usable after the handle is removed.
      expect(() => focus.addListener(() {}), returnsNormally);
      semantics.dispose();
    },
  );

  testWidgets(
    'rejected updates and disabled controls do not keep optimistic state',
    (tester) async {
      final changes = <double>[];
      final focus = FocusNode();
      addTearDown(focus.dispose);
      Widget app({bool enabled = true, double value = 260}) => MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              IanvsResizeHandle(
                value: value,
                min: 220,
                max: 320,
                focusNode: focus,
                semanticLabel: 'Sidebar width',
                onChanged: enabled ? changes.add : null,
              ),
            ],
          ),
        ),
      );
      await tester.pumpWidget(app());
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(changes, [280, 280]);
      await tester.pumpWidget(app(value: 300));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      expect(changes.last, 280);
      changes.clear();
      await tester.pumpWidget(app(enabled: false));
      await tester.drag(find.byType(IanvsResizeHandle), const Offset(80, 0));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      expect(changes, isEmpty);
    },
  );

  testWidgets(
    'vertical keys use physical direction while modifiers stay with host',
    (tester) async {
      final requests = <double>[];
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                IanvsResizeHandle(
                  value: 260,
                  min: 220,
                  max: 320,
                  axis: Axis.vertical,
                  reverse: true,
                  focusNode: focus,
                  semanticLabel: 'Terminal height',
                  onChanged: requests.add,
                ),
              ],
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      expect(requests, [280, 240]);
    },
  );
}
