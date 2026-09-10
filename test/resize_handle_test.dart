import 'dart:ui' show SemanticsAction;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

void main() {
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
