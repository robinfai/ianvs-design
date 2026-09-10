import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

Widget host(Widget child, Brightness brightness, IanvsDensity density) =>
    MaterialApp(
      theme: IanvsTheme.build(
        brightness: brightness,
        density: density,
        platform: TargetPlatform.macOS,
      ),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(24), child: child),
      ),
    );

void main() {
  for (final brightness in Brightness.values) {
    for (final density in IanvsDensity.values) {
      testWidgets(
        'search text stays vertically centered, including expanded view $brightness $density',
        (tester) async {
          await tester.pumpWidget(
            host(
              Column(
                children: [
                  SearchAnchor.bar(
                    barHintText: '搜索连接',
                    suggestionsBuilder: (_, controller) => [
                      ListTile(
                        title: const Text('Local Shell'),
                        onTap: () => controller.closeView('Local Shell'),
                      ),
                    ],
                  ),
                ],
              ),
              brightness,
              density,
            ),
          );
          await tester.pumpAndSettle();
          void expectCentered() {
            final bar = find.byType(SearchBar).last;
            final editable = find.descendant(
              of: bar,
              matching: find.byType(EditableText),
            );
            expect(
              (tester.getCenter(editable).dy - tester.getCenter(bar).dy).abs(),
              lessThanOrEqualTo(1),
            );
          }

          expectCentered();
          await tester.tap(find.byType(SearchBar));
          await tester.pumpAndSettle();
          await tester.enterText(find.byType(TextField).last, 'Local');
          await tester.pumpAndSettle();
          expectCentered();
          expect(tester.takeException(), isNull);
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
        },
      );
    }

    testWidgets(
      'select uses compact bounded menu with visibly disabled items $brightness',
      (tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            Column(
              children: [
                IanvsSelect<String>(
                  value: 'shell',
                  labelText: '连接类型',
                  options: const [
                    IanvsOption('shell', '登录 Shell'),
                    IanvsOption('ssh', 'SSH'),
                    IanvsOption('disabled', '不可用连接', enabled: false),
                  ],
                  onChanged: (value) => chosen = value,
                ),
              ],
            ),
            brightness,
            IanvsDensity.compact,
          ),
        );
        await tester.tap(find.byType(IanvsSelect<String>));
        await tester.pumpAndSettle();
        final row = find.widgetWithText(MenuItemButton, 'SSH');
        expect(tester.getSize(row).height, 40);
        expect(tester.getSize(row).width, 352);
        final disabled = tester.widget<MenuItemButton>(
          find.widgetWithText(MenuItemButton, '不可用连接'),
        );
        expect(disabled.onPressed, isNull);
        final t = Theme.of(tester.element(row)).extension<IanvsTokens>()!;
        expect(
          disabled.style!.foregroundColor!.resolve({WidgetState.disabled}),
          t.subtle,
        );
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(chosen, isNull);
        expect(row, findsNothing);
      },
    );

    testWidgets(
      'autocomplete panel stays compact and keyboard selection remains active $brightness',
      (tester) async {
        String? chosen;
        await tester.pumpWidget(
          host(
            Column(
              children: [
                Autocomplete<String>(
                  optionsBuilder: (value) =>
                      ['Local Shell', 'Local Server', 'Location'].where(
                        (s) =>
                            s.toLowerCase().contains(value.text.toLowerCase()),
                      ),
                  onSelected: (value) => chosen = value,
                  optionsViewBuilder: (context, onSelected, options) =>
                      IanvsAutocompleteOptions<String>(
                        options: options,
                        onSelected: onSelected,
                      ),
                ),
              ],
            ),
            brightness,
            IanvsDensity.compact,
          ),
        );
        await tester.enterText(find.byType(TextField), 'loc');
        await tester.pumpAndSettle();
        final list = find.descendant(
          of: find.byType(IanvsAutocompleteOptions<String>),
          matching: find.byType(ListView),
        );
        expect(tester.getSize(list).width, lessThanOrEqualTo(360));
        expect(tester.getSize(list).height, lessThan(160));
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
        expect(chosen, 'Local Server');
        expect(find.byType(IanvsAutocompleteOptions<String>), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
