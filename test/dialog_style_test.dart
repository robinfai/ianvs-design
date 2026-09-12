import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

Material materialWithin(WidgetTester tester, Finder parent) =>
    tester.widget<Material>(
      find.descendant(of: parent, matching: find.byType(Material)).first,
    );

void main() {
  for (final brightness in Brightness.values) {
    for (final kind in ['Dialog', 'AlertDialog', 'IanvsDialog']) {
      testWidgets(
        'soft $kind keeps cards, fields and keyboard focus $brightness',
        (tester) async {
          final theme = IanvsTheme.build(brightness: brightness);
          final tokens = theme.extension<IanvsTokens>()!;
          final fieldFocus = FocusNode();
          final cancelFocus = FocusNode();
          addTearDown(fieldFocus.dispose);
          addTearDown(cancelFocus.dispose);
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (context) {
                        final content = SizedBox(
                          width: 320,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Card(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('Content card'),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                focusNode: fieldFocus,
                                decoration: const InputDecoration(
                                  labelText: 'Name',
                                ),
                              ),
                              TextButton(
                                focusNode: cancelFocus,
                                autofocus: true,
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        );
                        return switch (kind) {
                          'Dialog' => Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: content,
                            ),
                          ),
                          'AlertDialog' => AlertDialog(
                            title: const Text('Details'),
                            content: content,
                          ),
                          _ => IanvsDialog(
                            title: const Text('Details'),
                            content: content,
                          ),
                        };
                      },
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Open'));
          await tester.pumpAndSettle();
          final dialog = materialWithin(tester, find.byType(Dialog));
          final shape = dialog.shape! as RoundedRectangleBorder;
          expect(shape.borderRadius, BorderRadius.circular(16));
          expect(shape.side, BorderSide(color: tokens.separator, width: .75));
          expect(dialog.color, tokens.raised);
          expect(dialog.surfaceTintColor, Colors.transparent);
          expect(dialog.elevation, 4);
          expect(dialog.shadowColor!.a, greaterThan(0));
          expect(dialog.shadowColor!.a, lessThan(.25));

          final card = materialWithin(tester, find.byType(Card));
          final cardShape = card.shape! as RoundedRectangleBorder;
          expect(cardShape.borderRadius, BorderRadius.circular(10));
          expect(cardShape.side, BorderSide(color: tokens.border));
          expect(card.elevation, 0);

          expect(cancelFocus.hasPrimaryFocus, isTrue);
          await tester.sendKeyEvent(LogicalKeyboardKey.tab);
          await tester.pumpAndSettle();
          expect(fieldFocus.hasPrimaryFocus, isTrue);
          final field = tester.widget<InputDecorator>(
            find.byType(InputDecorator),
          );
          expect(field.isFocused, isTrue);
          final focusedBorder =
              field.decoration.focusedBorder! as OutlineInputBorder;
          expect(
            focusedBorder.borderSide,
            BorderSide(color: tokens.focus, width: 2),
          );
          expect(
            focusedBorder.borderRadius,
            BorderRadius.circular(tokens.controlRadius),
          );
          await tester.enterText(find.byType(TextField), 'Panel');
          await tester.sendKeyEvent(LogicalKeyboardKey.escape);
          await tester.pumpAndSettle();
          expect(find.byType(Dialog), findsNothing);
          expect(tester.takeException(), isNull);
        },
        variant: TargetPlatformVariant.only(TargetPlatform.macOS),
      );
    }
  }
}
