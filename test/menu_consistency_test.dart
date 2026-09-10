import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';
import 'search_menu_test.dart' show host;

Future<ByteData> pixels(WidgetTester tester, GlobalKey key) async =>
    (await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      image.dispose();
      return data!;
    }))!;

Rect fieldRect(WidgetTester tester, Finder field) {
  final decorator = find.descendant(
    of: field,
    matching: find.byType(InputDecorator),
  );
  final content = find
      .descendant(
        of: decorator,
        matching: find.byWidgetPredicate(
          (w) => w is RichText || w is EditableText,
        ),
      )
      .first;
  final box = InputDecorator.containerOf(tester.element(content))!;
  return box.localToGlobal(Offset.zero) & box.size;
}

void main() {
  for (final brightness in Brightness.values) {
    for (final density in IanvsDensity.values) {
      testWidgets(
        'select hover stays inside outline including helper $brightness $density',
        (tester) async {
          final boundary = GlobalKey();
          await tester.pumpWidget(
            RepaintBoundary(
              key: boundary,
              child: host(
                Column(
                  children: [
                    IanvsSelect<String>(
                      value: 'shell',
                      labelText: 'Connection type',
                      helperText: 'Choose a connection',
                      options: const [IanvsOption('shell', 'Login Shell')],
                      onChanged: (_) {},
                    ),
                  ],
                ),
                brightness,
                density,
              ),
            ),
          );
          await tester.pumpAndSettle();
          final before = await pixels(tester, boundary);
          final field = find.byType(IanvsSelect<String>);
          final rect = fieldRect(tester, field);
          final mouse = await tester.createGesture(
            kind: PointerDeviceKind.mouse,
          );
          await mouse.addPointer(location: Offset.zero);
          await mouse.moveTo(rect.center);
          await tester.pumpAndSettle();
          final after = await pixels(tester, boundary);
          final width = tester.getSize(find.byKey(boundary)).width.toInt();
          var insideChanges = 0;
          var outsideChanges = 0;
          for (var i = 0; i < before.lengthInBytes; i += 4) {
            if (before.getUint32(i) == after.getUint32(i)) continue;
            final point = Offset(
              (i ~/ 4 % width).toDouble() + .5,
              (i ~/ 4 ~/ width).toDouble() + .5,
            );
            if (rect.inflate(1).contains(point)) {
              insideChanges++;
            } else {
              outsideChanges++;
            }
          }
          expect(
            insideChanges,
            greaterThan(0),
            reason: 'Hover must still be visible in the field.',
          );
          expect(
            outsideChanges,
            0,
            reason: 'No ink may leak below the outline or behind helper text.',
          );
          await mouse.removePointer();
        },
      );

      testWidgets(
        'select and Material dropdown align in size and text $brightness $density',
        (tester) async {
          await tester.pumpWidget(
            host(
              Column(
                children: [
                  IanvsSelect<String>(
                    value: 'shell',
                    options: const [IanvsOption('shell', 'Login Shell')],
                    onChanged: (_) {},
                  ),
                  const SizedBox(height: 16),
                  DropdownMenu<String>(
                    initialSelection: 'shell',
                    expandedInsets: EdgeInsets.zero,
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 'shell', label: 'Login Shell'),
                    ],
                  ),
                ],
              ),
              brightness,
              density,
            ),
          );
          await tester.pumpAndSettle();
          final select = fieldRect(tester, find.byType(IanvsSelect<String>));
          final dropdown = fieldRect(tester, find.byType(DropdownMenu<String>));
          expect(select.width, dropdown.width);
          expect(select.height, closeTo(dropdown.height, 1));
          final selectText = find.descendant(
            of: find.byType(IanvsSelect<String>),
            matching: find.text('Login Shell'),
          );
          final nativeText = find.byType(EditableText);
          expect(
            tester.getCenter(selectText).dy - select.center.dy,
            closeTo(tester.getCenter(nativeText).dy - dropdown.center.dy, 1),
          );
          final selectArrow = find.descendant(
            of: find.byType(IanvsSelect<String>),
            matching: find.byIcon(Icons.arrow_drop_down),
          );
          final materialArrow = find.descendant(
            of: find.byType(DropdownMenu<String>),
            matching: find.byIcon(Icons.arrow_drop_down),
          );
          expect(
            select.right - tester.getCenter(selectArrow).dx,
            closeTo(dropdown.right - tester.getCenter(materialArrow).dx, 1),
          );
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'menu families share actual selected surface and typography $brightness',
      (tester) async {
        Widget families() => Column(
          children: [
            IanvsSelect<String>(
              value: 'a',
              options: const [IanvsOption('a', 'Select item')],
              onChanged: (_) {},
            ),
            DropdownMenu<String>(
              initialSelection: 'a',
              expandedInsets: EdgeInsets.zero,
              dropdownMenuEntries: const [
                DropdownMenuEntry(value: 'a', label: 'Material item'),
              ],
            ),
            IanvsMenuButton<String>(
              tooltip: 'Choices',
              value: 'a',
              onSelected: (_) {},
              options: const [IanvsOption('a', 'Menu item')],
              child: const Text('Open choices'),
            ),
            Autocomplete<String>(
              optionsBuilder: (_) => ['Auto item'],
              optionsViewBuilder: (_, onSelected, options) =>
                  IanvsAutocompleteOptions(
                    options: options,
                    onSelected: onSelected,
                  ),
            ),
          ],
        );
        for (final kind in ['Select', 'Material', 'Menu', 'Auto']) {
          await tester.pumpWidget(
            host(families(), brightness, IanvsDensity.compact),
          );
          await tester.pumpAndSettle();
          if (kind == 'Select') {
            await tester.tap(find.byType(IanvsSelect<String>));
          }
          if (kind == 'Material') {
            await tester.tap(find.byType(DropdownMenu<String>));
          }
          if (kind == 'Menu') await tester.tap(find.text('Open choices'));
          if (kind == 'Auto') {
            await tester.enterText(find.byType(TextField).last, 'Auto');
          }
          await tester.pumpAndSettle();
          final row = find.widgetWithText(MenuItemButton, '$kind item').last;
          final t = Theme.of(tester.element(row)).extension<IanvsTokens>()!;
          final material = tester.widget<Material>(
            find.descendant(of: row, matching: find.byType(Material)).first,
          );
          expect(
            material.color,
            t.selected,
            reason: '$kind selected background',
          );
          expect(tester.getSize(row).height, 40);
          if (kind == 'Menu') {
            expect(tester.getSize(row).width, greaterThanOrEqualTo(152));
          }
          final text = tester.element(
            find.descendant(of: row, matching: find.text('$kind item')),
          );
          expect(DefaultTextStyle.of(text).style.fontSize, 14);
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
        }
      },
    );
  }

  testWidgets('choice menu skips disabled items and restores keyboard focus', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      host(
        IanvsMenuButton<String>(
          tooltip: 'Choices',
          value: 'a',
          options: const [
            IanvsOption('a', 'First'),
            IanvsOption('b', 'Disabled', enabled: false),
            IanvsOption('c', 'Last'),
          ],
          onSelected: (v) => selected = v,
          child: const Text('Open'),
        ),
        Brightness.dark,
        IanvsDensity.compact,
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(selected, 'c');
    expect(find.widgetWithText(MenuItemButton, 'Last'), findsNothing);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(MenuItemButton, 'Last'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(MenuItemButton, 'Last'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
