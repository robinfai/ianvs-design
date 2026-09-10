import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';
import 'search_menu_test.dart' show host;

const connections = [
  IanvsOption('shell', 'Local Shell'),
  IanvsOption('server', 'Local Server'),
  IanvsOption('codex', 'Codex'),
];

void main() {
  for (final brightness in Brightness.values) {
    for (final density in IanvsDensity.values) {
      testWidgets(
        'search opens in place without moving field or neighbours $brightness $density',
        (tester) async {
          await tester.pumpWidget(
            host(
              Column(
                children: [
                  IanvsSearchField<String>(
                    hintText: 'Search connections',
                    options: connections,
                    onSelected: (_) {},
                  ),
                  const SizedBox(height: 16),
                  const TextField(key: ValueKey('next')),
                ],
              ),
              brightness,
              density,
            ),
          );
          await tester.pumpAndSettle();
          final search = find.byType(SearchBar);
          final rect = tester.getRect(search);
          final nextRect = tester.getRect(find.byKey(const ValueKey('next')));
          await tester.tap(search);
          await tester.pumpAndSettle();
          expect(tester.getRect(search), rect);
          expect(tester.getRect(find.byKey(const ValueKey('next'))), nextRect);
          expect(find.byType(SearchBar), findsOneWidget);
          expect(find.byIcon(Icons.search), findsOneWidget);
          expect(find.byIcon(Icons.arrow_back), findsNothing);
          final row = find.widgetWithText(MenuItemButton, 'Local Shell');
          expect(row, findsOneWidget);
          expect(
            tester.getTopLeft(row).dy,
            greaterThanOrEqualTo(rect.bottom + 4),
          );
          expect(tester.getSize(row).width, lessThanOrEqualTo(352));
          final editable = find.descendant(
            of: search,
            matching: find.byType(EditableText),
          );
          expect(
            (tester.getCenter(editable).dy - rect.center.dy).abs(),
            lessThanOrEqualTo(1),
          );
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(row, findsNothing);
          expect(
            tester.widget<EditableText>(editable).focusNode.hasFocus,
            isTrue,
          );
          expect(tester.getRect(search), rect);
          await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
          await tester.pumpAndSettle();
          expect(row, findsOneWidget);
          await tester.tapAt(
            const Offset(750, 550),
            kind: PointerDeviceKind.mouse,
          );
          await tester.pumpAndSettle();
          expect(
            row,
            findsNothing,
            reason:
                'A blank outside click must not reopen the menu via focus restoration.',
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'search supports keyboard, empty results, dismissal and reopening $brightness',
      (tester) async {
        String? chosen;
        final controller = TextEditingController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          host(
            Column(
              children: [
                IanvsSearchField<String>(
                  controller: controller,
                  options: connections,
                  onSelected: (v) => chosen = v,
                ),
                const SizedBox(height: 330),
                const TextField(key: ValueKey('next')),
              ],
            ),
            brightness,
            IanvsDensity.compact,
          ),
        );
        await tester.tap(find.byType(SearchBar));
        await tester.pumpAndSettle();
        final field = find.descendant(
          of: find.byType(SearchBar),
          matching: find.byType(TextField),
        );
        await tester.enterText(field, 'loc');
        await tester.pumpAndSettle();
        expect(find.widgetWithText(MenuItemButton, 'Codex'), findsNothing);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();
        expect(chosen, 'server');
        expect(controller.text, 'Local Server');
        expect(find.byType(MenuItemButton), findsNothing);
        await tester.tap(field);
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(MenuItemButton, 'Local Server'),
          findsOneWidget,
        );
        await tester.enterText(field, 'no-such-connection');
        await tester.pumpAndSettle();
        expect(find.text('没有匹配结果'), findsOneWidget);
        await tester.tap(find.byKey(const ValueKey('next')));
        await tester.pumpAndSettle();
        expect(find.text('没有匹配结果'), findsNothing);
        expect(
          tester
                  .widget<TextField>(find.byKey(const ValueKey('next')))
                  .focusNode
                  ?.hasFocus ??
              tester
                  .widget<EditableText>(
                    find.descendant(
                      of: find.byKey(const ValueKey('next')),
                      matching: find.byType(EditableText),
                    ),
                  )
                  .focusNode
                  .hasFocus,
          isTrue,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'mouse can select a suggestion without losing input focus $brightness',
      (tester) async {
        String? chosen;
        final focus = FocusNode();
        final controller = TextEditingController();
        addTearDown(focus.dispose);
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          host(
            Column(
              children: [
                IanvsSearchField<String>(
                  focusNode: focus,
                  controller: controller,
                  options: connections,
                  onSelected: (v) => chosen = v,
                ),
              ],
            ),
            brightness,
            IanvsDensity.compact,
          ),
        );
        await tester.tap(find.byType(SearchBar));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(MenuItemButton, 'Codex'),
          kind: PointerDeviceKind.mouse,
        );
        await tester.pumpAndSettle();
        expect(chosen, 'codex');
        expect(controller.text, 'Codex');
        expect(focus.hasFocus, isTrue);
        expect(find.byType(MenuItemButton), findsNothing);
        await tester.pumpWidget(const SizedBox());
        // External controller and focus are still owned by the caller.
        controller.text = 'still valid';
        focus.requestFocus();
        expect(tester.takeException(), isNull);
      },
    );
  }
}
