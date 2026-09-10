import 'dart:ui' show CheckedState;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

Widget host(Widget child) => MaterialApp(
  theme: IanvsTheme.build(brightness: Brightness.dark),
  home: Scaffold(
    body: Center(child: SizedBox(width: 380, child: child)),
  ),
);

Future<void> mouseClick(WidgetTester tester, Offset position) async {
  final mouse = await tester.startGesture(
    position,
    kind: PointerDeviceKind.mouse,
  );
  await mouse.up();
  await mouse.removePointer();
  await tester.pump();
}

Offset textPosition(WidgetTester tester, int offset) {
  final editable = tester.state<EditableTextState>(find.byType(EditableText));
  final render = editable.renderEditable;
  return render.localToGlobal(
    render.getLocalRectForCaret(TextPosition(offset: offset)).center,
  );
}

void testOnMac(String name, WidgetTesterCallback callback) => testWidgets(
  name,
  callback,
  variant: TargetPlatformVariant.only(TargetPlatform.macOS),
);

void main() {
  testOnMac('label and checkbox act once and retain native keyboard focus', (
    tester,
  ) async {
    var value = false;
    var calls = 0;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            void change(bool next) => setState(() {
              calls++;
              value = next;
            });
            return IanvsControlLabel(
              label: 'Restore workspace',
              onTap: () => change(!value),
              controlBuilder: (focus) => Checkbox(
                value: value,
                focusNode: focus,
                onChanged: (next) => change(next!),
              ),
            );
          },
        ),
      ),
    );
    await mouseClick(tester, textPosition(tester, 3));
    expect(calls, 0);
    await tester.pump(kDoubleTapTimeout);
    await tester.pump();
    expect(value, isTrue);
    expect(calls, 1);
    expect(
      tester.widget<Checkbox>(find.byType(Checkbox)).focusNode!.hasFocus,
      isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(value, isFalse);
    expect(calls, 2);
    await mouseClick(tester, tester.getCenter(find.byType(Checkbox)));
    await tester.pump(kDoubleTapTimeout);
    expect(value, isTrue);
    expect(calls, 3);
  });

  for (final gesture in ['drag', 'double click', 'long press']) {
    testOnMac('$gesture selects copyable text without changing the control', (
      tester,
    ) async {
      var calls = 0;
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        host(
          IanvsControlLabel(
            label: 'Restore workspace',
            onTap: () => calls++,
            controlBuilder: (focus) => Checkbox(
              value: false,
              focusNode: focus,
              onChanged: (_) => calls++,
            ),
          ),
        ),
      );
      if (gesture == 'drag') {
        final mouse = await tester.startGesture(
          textPosition(tester, 1),
          kind: PointerDeviceKind.mouse,
        );
        await mouse.moveTo(textPosition(tester, 7));
        await mouse.up();
        await mouse.removePointer();
      } else if (gesture == 'double click') {
        await mouseClick(tester, textPosition(tester, 3));
        await tester.pump(const Duration(milliseconds: 80));
        await mouseClick(tester, textPosition(tester, 3));
      } else {
        await tester.longPressAt(textPosition(tester, 3));
      }
      await tester.pump(kDoubleTapTimeout);
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.controller.selection.isCollapsed, isFalse);
      final expected = editable.controller.selection.textInside(
        editable.controller.text,
      );
      await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyC);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
      await tester.pump();
      expect(copied, expected);
      expect(calls, 0);
    });
  }

  testOnMac('disabled label can be selected but never activates', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        IanvsControlLabel(
          label: 'Disabled option',
          onTap: null,
          controlBuilder: (focus) =>
              Checkbox(value: false, focusNode: focus, onChanged: null),
        ),
      ),
    );
    await mouseClick(tester, textPosition(tester, 3));
    await tester.pump(kDoubleTapTimeout);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    await mouseClick(tester, textPosition(tester, 3));
    await tester.pump(const Duration(milliseconds: 80));
    await mouseClick(tester, textPosition(tester, 3));
    await tester.pump(kDoubleTapTimeout);
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText))
          .controller
          .selection
          .isCollapsed,
      isFalse,
    );
  });

  testOnMac('control click cancels a pending label action', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      host(
        IanvsControlLabel(
          label: 'Restore workspace',
          onTap: () => calls++,
          controlBuilder: (focus) => Checkbox(
            value: false,
            focusNode: focus,
            onChanged: (_) => calls++,
          ),
        ),
      ),
    );
    await mouseClick(tester, textPosition(tester, 3));
    await mouseClick(tester, tester.getCenter(find.byType(Checkbox)));
    await tester.pump(kDoubleTapTimeout);
    expect(calls, 1);
  });

  testOnMac('disabling or removing label cancels a pending action', (
    tester,
  ) async {
    var calls = 0;
    Widget label(bool enabled) => host(
      IanvsControlLabel(
        label: 'Restore workspace',
        onTap: enabled ? () => calls++ : null,
        controlBuilder: (focus) => Checkbox(
          value: false,
          focusNode: focus,
          onChanged: enabled ? (_) => calls++ : null,
        ),
      ),
    );
    await tester.pumpWidget(label(true));
    await mouseClick(tester, textPosition(tester, 3));
    await tester.pumpWidget(label(false));
    await tester.pump(kDoubleTapTimeout);
    expect(calls, 0);
    await tester.pumpWidget(label(true));
    await mouseClick(tester, textPosition(tester, 3));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(kDoubleTapTimeout);
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });

  testOnMac('label adds a native accessible name with no extra Tab stop', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final nextFocus = FocusNode();
    addTearDown(nextFocus.dispose);
    await tester.pumpWidget(
      host(
        Column(
          children: [
            IanvsControlLabel(
              label: 'Restore workspace',
              onTap: () {},
              controlBuilder: (focus) =>
                  Checkbox(value: true, focusNode: focus, onChanged: (_) {}),
            ),
            TextButton(
              focusNode: nextFocus,
              onPressed: () {},
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
    final node = tester.getSemantics(
      find.bySemanticsLabel('Restore workspace'),
    );
    expect(node.flagsCollection.isChecked, CheckedState.isTrue);
    expect(node.flagsCollection.isTextField, isFalse);
    tester.widget<Checkbox>(find.byType(Checkbox)).focusNode!.requestFocus();
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(nextFocus.hasFocus, isTrue);
    semantics.dispose();
  });

  testOnMac('settings title and description operate the same switch', (
    tester,
  ) async {
    var value = false;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) {
            return IanvsSettingsRow(
              title: 'Restore workspace',
              description: 'Save the previous layout.',
              value: value,
              onChanged: (next) => setState(() => value = next),
            );
          },
        ),
      ),
    );
    await mouseClick(tester, textPosition(tester, 3));
    await tester.pump(kDoubleTapTimeout);
    expect(value, isTrue);
    await mouseClick(tester, textPosition(tester, 22));
    await tester.pump(kDoubleTapTimeout);
    expect(value, isFalse);
  });
}
