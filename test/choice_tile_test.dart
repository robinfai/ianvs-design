import 'dart:ui' show CheckedState, SemanticsAction;
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

Widget host(
  Widget child, {
  bool touch = false,
  Brightness brightness = Brightness.light,
  double scale = 1,
  bool reduceMotion = false,
  TextDirection direction = TextDirection.ltr,
}) => MaterialApp(
  theme: IanvsTheme.build(
    brightness: brightness,
    platform: touch ? TargetPlatform.iOS : TargetPlatform.macOS,
    density: touch ? IanvsDensity.touch : IanvsDensity.compact,
    touchVisualDensity: IanvsTouchVisualDensity.compact,
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: reduceMotion,
    ),
    child: Directionality(textDirection: direction, child: child!),
  ),
  home: Scaffold(
    body: Center(
      child: SizedBox(width: 340, child: SingleChildScrollView(child: child)),
    ),
  ),
);

Finder tile(int value) => find.byKey(ValueKey(value));
Finder surface(int value) =>
    find.descendant(of: tile(value), matching: find.byType(AnimatedContainer));
BoxDecoration decoration(WidgetTester tester, int value) =>
    tester.widget<AnimatedContainer>(surface(value)).decoration!
        as BoxDecoration;

void main() {
  testWidgets(
    'selection stays controlled and trailing space is stable in RTL',
    (tester) async {
      int? requested;
      var selected = 1;
      late StateSetter rebuild;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return RadioGroup<int>(
                groupValue: selected,
                onChanged: (next) => requested = next,
                child: const Column(
                  children: [
                    IanvsChoiceTile(
                      value: 1,
                      key: ValueKey(1),
                      title: Text('One'),
                    ),
                    IanvsChoiceTile(
                      value: 2,
                      key: ValueKey(2),
                      title: Text('Two'),
                    ),
                  ],
                ),
              );
            },
          ),
          direction: TextDirection.rtl,
        ),
      );
      Finder slot(int value) => find.descendant(
        of: tile(value),
        matching: find.byWidgetPredicate(
          (w) => w is SizedBox && w.width == 20 && w.height == 20,
        ),
      );
      final before = tester.getRect(slot(2));
      expect(before.right, lessThan(tester.getRect(find.text('Two')).left));
      expect(tester.getSize(tile(1)).height, 32);
      await tester.tap(tile(2));
      await tester.pumpAndSettle();
      expect(requested, 2);
      expect(
        find.descendant(of: tile(2), matching: find.byIcon(Icons.check)),
        findsNothing,
      );
      rebuild(() => selected = 2);
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: tile(2), matching: find.byIcon(Icons.check)),
        findsOneWidget,
      );
      expect(tester.getRect(slot(2)), before);
    },
  );
  testWidgets('whole row uses one radio node and a controlled group', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var value = 1;
    var calls = 0;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => RadioGroup<int>(
            groupValue: value,
            onChanged: (next) => setState(() {
              value = next!;
              calls++;
            }),
            child: const Column(
              children: [
                IanvsChoiceTile(
                  value: 1,
                  key: ValueKey(1),
                  title: Text('Local'),
                  subtitle: Text('On this device'),
                ),
                IanvsChoiceTile(
                  value: 2,
                  key: ValueKey(2),
                  title: Text('Remote'),
                  subtitle: Text('Other devices'),
                ),
                IanvsChoiceTile(
                  value: 3,
                  key: ValueKey(3),
                  title: Text('Unavailable'),
                  enabled: false,
                ),
              ],
            ),
          ),
        ),
        touch: true,
      ),
    );
    final firstWidth = tester.getSize(find.text('Local')).width;
    final row = tester.getRect(tile(2));
    await tester.tapAt(Offset(row.right - 6, row.center.dy));
    await tester.pumpAndSettle();
    expect(value, 2);
    expect(calls, 1);
    await tester.tap(find.text('Other devices'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    await tester.tap(tile(3));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(tester.getSize(find.text('Local')).width, firstWidth);
    expect(
      find.descendant(of: tile(1), matching: find.byIcon(Icons.check)),
      findsNothing,
    );
    expect(
      find.descendant(of: tile(2), matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
    for (final id in [1, 2, 3]) {
      final data = tester.getSemantics(tile(id)).getSemanticsData();
      expect(data.flagsCollection.isInMutuallyExclusiveGroup, isTrue);
      expect(
        data.flagsCollection.isChecked,
        id == 2 ? CheckedState.isTrue : CheckedState.isFalse,
      );
      expect(data.hasAction(SemanticsAction.tap), id != 3);
    }
    expect(
      tester.getSemantics(tile(2)).getSemanticsData().label,
      'Remote\nOther devices',
    );
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('RadioGroup owns tab, space, arrows and disabled skipping', (
    tester,
  ) async {
    final before = FocusNode(),
        first = FocusNode(),
        second = FocusNode(),
        after = FocusNode();
    for (final node in [before, first, second, after]) {
      addTearDown(node.dispose);
    }
    int? value;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              TextButton(
                focusNode: before,
                onPressed: () {},
                child: const Text('Before'),
              ),
              RadioGroup<int>(
                groupValue: value,
                onChanged: (next) => setState(() => value = next),
                child: Column(
                  children: [
                    IanvsChoiceTile(
                      value: 1,
                      title: const Text('One'),
                      focusNode: first,
                    ),
                    const IanvsChoiceTile(
                      value: 3,
                      title: Text('Disabled'),
                      enabled: false,
                    ),
                    IanvsChoiceTile(
                      value: 2,
                      title: const Text('Two'),
                      focusNode: second,
                    ),
                  ],
                ),
              ),
              TextButton(
                focusNode: after,
                onPressed: () {},
                child: const Text('After'),
              ),
            ],
          ),
        ),
      ),
    );
    before.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(first.hasFocus, isTrue);
    expect(value, isNull);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();
    expect(value, 1);
    for (final (key, expected) in [
      (LogicalKeyboardKey.arrowDown, 2),
      (LogicalKeyboardKey.arrowRight, 1),
      (LogicalKeyboardKey.arrowUp, 2),
      (LogicalKeyboardKey.arrowLeft, 1),
    ]) {
      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();
      expect(value, expected);
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(after.hasFocus, isTrue);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.pump();
    expect(first.hasFocus, isTrue);
    await tester.pumpWidget(const SizedBox());
    // The component never disposes the host-owned focus node.
    first.addListener(() {});
  });

  for (final brightness in Brightness.values) {
    for (final touch in [false, true]) {
      for (final scale in [1.0, 2.0, 3.0]) {
        testWidgets(
          'long choices grow $brightness / touch=$touch / scale=$scale',
          (tester) async {
            var value = 1;
            await tester.pumpWidget(
              host(
                StatefulBuilder(
                  builder: (context, setState) => RadioGroup<int>(
                    groupValue: value,
                    onChanged: (next) => setState(() => value = next!),
                    child: const Column(
                      children: [
                        IanvsChoiceTile(
                          value: 1,
                          key: ValueKey(1),
                          title: Text(
                            '保存完整的设备配置 Save the complete device configuration',
                          ),
                          subtitle: Text(
                            '此设置会应用到所有关联设备。This setting applies to all associated devices.',
                          ),
                        ),
                        IanvsChoiceTile(
                          value: 2,
                          key: ValueKey(2),
                          title: Text('Other'),
                        ),
                      ],
                    ),
                  ),
                ),
                brightness: brightness,
                touch: touch,
                scale: scale,
              ),
            );
            expect(tester.takeException(), isNull);
            expect(
              tester.getSize(tile(2)).height,
              greaterThanOrEqualTo(touch ? 48 : 32),
            );
            expect(
              tester.getSize(tile(1)).height,
              greaterThan(tester.getSize(tile(2)).height),
            );
            final text = find.text(
              '保存完整的设备配置 Save the complete device configuration',
            );
            expect(
              tester.getRect(text).right,
              lessThan(tester.getRect(tile(1)).right - 30),
            );
            await tester.ensureVisible(tile(2));
            await tester.pumpAndSettle();
            await tester.tap(tile(2));
            await tester.pumpAndSettle();
            expect(value, 2);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets('neutral hover, focus outline and reduced motion $brightness', (
      tester,
    ) async {
      final strategy = FocusManager.instance.highlightStrategy;
      FocusManager.instance.highlightStrategy =
          FocusHighlightStrategy.alwaysTraditional;
      addTearDown(() => FocusManager.instance.highlightStrategy = strategy);
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        host(
          RadioGroup<int>(
            groupValue: 1,
            onChanged: (_) {},
            child: Column(
              children: [
                IanvsChoiceTile(
                  value: 1,
                  key: const ValueKey(1),
                  title: const Text('Selected'),
                  focusNode: focus,
                ),
                const IanvsChoiceTile(
                  value: 2,
                  key: ValueKey(2),
                  title: Text('Disabled'),
                  enabled: false,
                ),
              ],
            ),
          ),
          brightness: brightness,
          reduceMotion: true,
        ),
      );
      final t = IanvsTokens.of(tester.element(tile(1)));
      expect(decoration(tester, 1).color, Colors.transparent);
      expect(
        tester.widget<AnimatedContainer>(surface(1)).duration,
        Duration.zero,
      );
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(tile(1)));
      await tester.pumpAndSettle();
      expect(decoration(tester, 1).color, t.text.withValues(alpha: .05));
      focus.requestFocus();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      expect(
        decoration(tester, 1).border,
        Border.all(color: t.focus, width: 2),
      );
      await mouse.moveTo(tester.getCenter(tile(2)));
      await tester.pumpAndSettle();
      expect(decoration(tester, 2).color, Colors.transparent);
      await mouse.removePointer();
    });
  }
}
