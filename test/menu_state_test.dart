import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';
import 'package:ianvs_design/src/foundation/menu_style.dart';
import 'search_menu_test.dart' show host;
import 'theme_test.dart' show contrast;

Material menuMaterial(WidgetTester tester, Finder row) =>
    tester.widget<Material>(
      find.descendant(of: row, matching: find.byType(Material)).first,
    );

void expectBorderless(WidgetTester tester, Finder row) {
  final shape = menuMaterial(tester, row).shape! as OutlinedBorder;
  expect(shape.side.style, BorderStyle.none);
}

void main() {
  for (final brightness in Brightness.values) {
    final tokens = brightness == Brightness.light
        ? IanvsTokens.light
        : IanvsTokens.dark;

    test(
      'menu feedback stays soft, readable and distinct from selection $brightness',
      () {
        final style = IanvsMenuStyle.item(tokens);
        for (final states in [
          {WidgetState.hovered},
          {WidgetState.focused},
          {WidgetState.hovered, WidgetState.focused},
          {WidgetState.pressed, WidgetState.hovered, WidgetState.focused},
        ]) {
          final background = style.backgroundColor!.resolve(states)!;
          final foreground = style.foregroundColor!.resolve(states)!;
          expect(background, isNot(Colors.transparent));
          expect(background, isNot(tokens.selected));
          expect(foreground, tokens.text);
          expect(style.iconColor!.resolve(states), foreground);
          expect(style.side!.resolve(states)!.style, BorderStyle.none);
          expect(style.overlayColor!.resolve(states), Colors.transparent);
          for (final surface in [tokens.raised, tokens.chrome]) {
            final composite = Color.alphaBlend(background, surface);
            expect(contrast(foreground, composite), greaterThanOrEqualTo(4.5));
            expect(contrast(composite, surface), lessThan(1.6));
          }
          final selectedStates = {...states, WidgetState.selected};
          for (final (selectedStyle, selection) in [
            (style, selectedStates),
            (IanvsMenuStyle.item(tokens, selected: true), states),
          ]) {
            expect(
              selectedStyle.backgroundColor!.resolve(selection),
              tokens.selected,
            );
            expect(
              selectedStyle.foregroundColor!.resolve(selection),
              tokens.onSelected,
            );
            expect(
              selectedStyle.side!.resolve(selection)!.style,
              BorderStyle.none,
            );
            final disabledStates = {...selection, WidgetState.disabled};
            expect(
              selectedStyle.backgroundColor!.resolve(disabledStates),
              Colors.transparent,
            );
            expect(
              selectedStyle.foregroundColor!.resolve(disabledStates),
              tokens.subtle,
            );
            expect(
              selectedStyle.side!.resolve(disabledStates)!.style,
              BorderStyle.none,
            );
          }
        }
      },
    );

    testWidgets(
      'SubmenuButton mouse hover plus focus and keyboard navigation are borderless $brightness',
      (tester) async {
        final submenuFocus = FocusNode();
        final firstFocus = FocusNode();
        final lastFocus = FocusNode();
        final siblingFocus = FocusNode();
        for (final node in [
          submenuFocus,
          firstFocus,
          lastFocus,
          siblingFocus,
        ]) {
          addTearDown(node.dispose);
        }
        String? chosen;
        final submenuController = MenuController();
        await tester.pumpWidget(
          host(
            MenuAnchor(
              menuChildren: [
                SubmenuButton(
                  focusNode: submenuFocus,
                  controller: submenuController,
                  menuChildren: [
                    MenuItemButton(
                      focusNode: firstFocus,
                      onPressed: () => chosen = 'first',
                      child: const Text('First model'),
                    ),
                    const MenuItemButton(child: Text('Unavailable model')),
                    MenuItemButton(
                      focusNode: lastFocus,
                      onPressed: () => chosen = 'last',
                      child: const Text('Last model'),
                    ),
                  ],
                  child: const Text('Models'),
                ),
                MenuItemButton(
                  focusNode: siblingFocus,
                  onPressed: () {},
                  child: const Text('Settings'),
                ),
              ],
              builder: (context, controller, child) => TextButton(
                onPressed: controller.open,
                child: const Text('Open menu'),
              ),
            ),
            brightness,
            IanvsDensity.compact,
          ),
        );
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: const Offset(790, 590));
        await mouse.down(tester.getCenter(find.text('Open menu')));
        await mouse.up();
        await tester.pumpAndSettle();
        final submenu = find.widgetWithText(SubmenuButton, 'Models');
        await mouse.moveTo(tester.getCenter(submenu));
        await tester.pumpAndSettle();
        expect(submenuFocus.hasPrimaryFocus, isTrue);
        expect(submenuController.isOpen, isTrue);
        final ink = tester.widget<InkWell>(
          find.descendant(of: submenu, matching: find.byType(InkWell)).first,
        );
        expect(
          ink.statesController!.value,
          containsAll([WidgetState.hovered, WidgetState.focused]),
        );
        expectBorderless(tester, submenu);
        final hoverColor = menuMaterial(tester, submenu).color!;
        expect(hoverColor, isNot(tokens.selected));
        expect(hoverColor, isNot(Colors.transparent));
        final label = tester.element(find.text('Models'));
        expect(DefaultTextStyle.of(label).style.color, tokens.text);

        // The opened submenu retains logical focus when the mouse leaves.
        // That focused-only state must also remain free of a blue outline.
        await mouse.moveTo(const Offset(790, 590));
        await tester.pumpAndSettle();
        expect(submenuFocus.hasPrimaryFocus, isTrue);
        expectBorderless(tester, submenu);
        expect(menuMaterial(tester, submenu).color, isNot(tokens.selected));

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        expect(firstFocus.hasPrimaryFocus, isTrue);
        final first = find.widgetWithText(MenuItemButton, 'First model');
        final last = find.widgetWithText(MenuItemButton, 'Last model');
        expectBorderless(tester, first);
        final focusColor = menuMaterial(tester, first).color!;
        expect(focusColor, isNot(Colors.transparent));
        expect(focusColor, isNot(tokens.selected));
        expect(menuMaterial(tester, last).color, Colors.transparent);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(lastFocus.hasPrimaryFocus, isTrue);
        expect(menuMaterial(tester, last).color, focusColor);
        expectBorderless(tester, last);
        await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
        await tester.pumpAndSettle();
        expect(firstFocus.hasPrimaryFocus, isTrue);
        expect(menuMaterial(tester, first).color, focusColor);
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        expect(lastFocus.hasPrimaryFocus, isTrue);
        expect(menuMaterial(tester, first).color, Colors.transparent);
        expect(menuMaterial(tester, last).color, focusColor);
        expectBorderless(tester, last);
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();
        expect(chosen, 'last');
        expect(find.text('Last model'), findsNothing);
        await mouse.removePointer();
      },
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    );
  }
}
