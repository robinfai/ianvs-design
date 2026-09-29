import 'dart:ui' show PointerDeviceKind, SemanticsAction;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

void main() {
  for (final axis in Axis.values) {
    testWidgets('default line remains centered for $axis', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 200,
                height: 160,
                child: Flex(
                  direction: axis,
                  children: [
                    IanvsResizeHandle(
                      value: 260,
                      min: 100,
                      max: 400,
                      onChanged: (_) {},
                      semanticLabel: 'Panel size',
                      axis: axis,
                    ),
                  ],
                ),
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
      expect(tester.getCenter(line), tester.getCenter(handle));
      final size = tester.getSize(handle);
      expect(axis == Axis.horizontal ? size.width : size.height, 8);
    });
  }

  for (final (axis, alignment) in [
    (Axis.horizontal, Alignment.centerLeft),
    (Axis.horizontal, Alignment.centerRight),
    (Axis.vertical, Alignment.topCenter),
    (Axis.vertical, Alignment.bottomCenter),
  ]) {
    for (final direction in TextDirection.values) {
      for (final reverse in [false, true]) {
        testWidgets(
          'edge $alignment keeps hit area and interactions $direction reverse=$reverse',
          (tester) async {
            final focus = FocusNode();
            addTearDown(focus.dispose);
            final semantics = tester.ensureSemantics();
            try {
              var value = 260.0;
              final horizontal = axis == Axis.horizontal;
              final nearEdge = horizontal ? alignment.x < 0 : alignment.y < 0;
              final sign = reverse ? -1 : 1;
              final theme = reverse ? IanvsTheme.dark() : IanvsTheme.light();
              await tester.pumpWidget(
                MaterialApp(
                  theme: theme,
                  home: Directionality(
                    textDirection: direction,
                    child: Scaffold(
                      body: Center(
                        child: SizedBox(
                          width: 200,
                          height: 160,
                          child: StatefulBuilder(
                            builder: (context, setState) => Flex(
                              direction: axis,
                              children: [
                                IanvsResizeHandle(
                                  value: value,
                                  min: 100,
                                  max: 400,
                                  resetValue: 260,
                                  onChanged: (next) =>
                                      setState(() => value = next),
                                  semanticLabel: 'Panel size',
                                  axis: axis,
                                  reverse: reverse,
                                  lineAlignment: alignment,
                                  hitExtent: 8,
                                  focusNode: focus,
                                ),
                              ],
                            ),
                          ),
                        ),
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
              final hitRect = tester.getRect(handle);
              void expectGeometry(double thickness) {
                final lineRect = tester.getRect(line);
                expect(tester.getRect(handle), hitRect);
                expect(horizontal ? hitRect.width : hitRect.height, 8);
                expect(
                  horizontal ? lineRect.width : lineRect.height,
                  thickness,
                );
                if (horizontal) {
                  expect(lineRect.top, hitRect.top);
                  expect(lineRect.bottom, hitRect.bottom);
                  expect(
                    nearEdge ? lineRect.left : lineRect.right,
                    nearEdge ? hitRect.left : hitRect.right,
                  );
                } else {
                  expect(lineRect.left, hitRect.left);
                  expect(lineRect.right, hitRect.right);
                  expect(
                    nearEdge ? lineRect.top : lineRect.bottom,
                    nearEdge ? hitRect.top : hitRect.bottom,
                  );
                }
                expect(hitRect.intersect(lineRect), lineRect);
                expect(tester.getSemantics(handle).rect.size, hitRect.size);
              }

              expectGeometry(1);
              await tester.sendKeyEvent(LogicalKeyboardKey.tab);
              await tester.pump();
              expect(focus.hasPrimaryFocus, isTrue);
              expectGeometry(2);

              // Start in the empty portion, not on the 1/2-point visible line.
              final start = horizontal
                  ? Offset(
                      nearEdge ? hitRect.right - 1 : hitRect.left + 1,
                      hitRect.center.dy,
                    )
                  : Offset(
                      hitRect.center.dx,
                      nearEdge ? hitRect.bottom - 1 : hitRect.top + 1,
                    );
              expect(tester.getRect(line).contains(start), isFalse);
              final mouse = await tester.createGesture(
                kind: PointerDeviceKind.mouse,
              );
              await mouse.addPointer(location: start);
              await mouse.down(start);
              final delta = horizontal
                  ? const Offset(24, 0)
                  : const Offset(0, 24);
              await mouse.moveBy(delta);
              await mouse.moveBy(delta);
              await tester.pump();
              expect(value, reverse ? lessThan(260) : greaterThan(260));
              expectGeometry(2);
              if (reverse) {
                await mouse.cancel();
              } else {
                await mouse.up();
              }
              await tester.pump();
              expect(focus.hasPrimaryFocus, isTrue);
              expectGeometry(1);

              final previous = value;
              await tester.sendKeyEvent(
                horizontal
                    ? LogicalKeyboardKey.arrowRight
                    : LogicalKeyboardKey.arrowDown,
              );
              await tester.pump();
              expect(value, previous + 20 * sign);
              expectGeometry(2);
              final node = tester.getSemantics(handle);
              expect(
                node.getSemanticsData().hasAction(SemanticsAction.increase),
                isTrue,
              );
              node.owner!.performAction(node.id, SemanticsAction.increase);
              await tester.pump();
              expect(value, previous + 20 * sign + 20);

              await mouse.removePointer();
              await tester.tapAt(start, kind: PointerDeviceKind.mouse);
              await tester.pump(const Duration(milliseconds: 50));
              await tester.tapAt(start, kind: PointerDeviceKind.mouse);
              await tester.pumpAndSettle();
              expect(value, 260);
              expectGeometry(1);
              expect(tester.takeException(), isNull);
            } finally {
              semantics.dispose();
            }
          },
          variant: TargetPlatformVariant.only(TargetPlatform.macOS),
        );
      }
    }
  }
}
