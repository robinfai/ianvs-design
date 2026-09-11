import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

Widget host(
  Widget child, {
  bool touch = false,
  double scale = 1,
  double width = 600,
}) => MaterialApp(
  theme: IanvsTheme.build(
    platform: touch ? TargetPlatform.iOS : TargetPlatform.macOS,
    density: touch ? IanvsDensity.touch : IanvsDensity.compact,
    touchVisualDensity: IanvsTouchVisualDensity.compact,
  ),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
    child: child!,
  ),
  home: Scaffold(
    body: SingleChildScrollView(
      child: SizedBox(width: width, child: child),
    ),
  ),
);

void main() {
  for (final touch in [false, true]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets(
        'consecutive settings have internal space touch=$touch scale=$scale',
        (tester) async {
          var value = false;
          await tester.pumpWidget(
            host(
              StatefulBuilder(
                builder: (context, setState) => Column(
                  children: [
                    IanvsSettingsRow(
                      key: const Key('short'),
                      title: 'Read files',
                      value: false,
                      onChanged: (_) {},
                    ),
                    IanvsSettingsRow(
                      key: const Key('description'),
                      title: 'Write files',
                      description: 'Allow changes to local documents',
                      value: value,
                      onChanged: (next) => setState(() => value = next),
                    ),
                    const IanvsSettingsRow(
                      key: Key('long'),
                      title:
                          '允许访问所有关联设备的配置 Allow access to the configuration of all associated devices',
                      description:
                          '仅在明确确认之后执行操作。Actions require explicit confirmation.',
                      value: false,
                      onChanged: null,
                    ),
                  ],
                ),
              ),
              touch: touch,
              scale: scale,
              width: 360,
            ),
          );
          for (final name in ['short', 'description', 'long']) {
            final row = find.byKey(Key(name));
            final rowRect = tester.getRect(row);
            final text = find.descendant(
              of: row,
              matching: find.byType(SelectableText),
            );
            final toggle = find.descendant(
              of: row,
              matching: find.byType(Switch),
            );
            expect(rowRect.height, greaterThanOrEqualTo(touch ? 48 : 40));
            for (final content in [text, toggle]) {
              final rect = tester.getRect(content);
              expect(rect.top - rowRect.top, greaterThanOrEqualTo(4));
              expect(rowRect.bottom - rect.bottom, greaterThanOrEqualTo(4));
            }
            expect(
              tester.getCenter(text).dy,
              closeTo(tester.getCenter(toggle).dy, .01),
            );
          }
          expect(
            tester.getSize(find.byKey(const Key('long'))).height,
            greaterThan(tester.getSize(find.byKey(const Key('short'))).height),
          );
          final toggle = find.descendant(
            of: find.byKey(const Key('description')),
            matching: find.byType(Switch),
          );
          tester.widget<Switch>(toggle).focusNode!.requestFocus();
          await tester.pump();
          await tester.sendKeyEvent(LogicalKeyboardKey.space);
          await tester.pumpAndSettle();
          expect(value, isTrue);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  for (final width in [360.0, 600.0]) {
    for (final scale in [1.0, 1.5, 2.0]) {
      testWidgets('macOS field and section alignment at $width / $scale', (
        tester,
      ) async {
        await tester.pumpWidget(
          host(
            IanvsFormSection(
              title: const Text('连接设置 Connection configuration'),
              trailing: IanvsButton(
                onPressed: () {},
                child: const Text('恢复默认值 Restore defaults'),
              ),
              spacing: 12,
              children: [
                const IanvsFieldRow(
                  key: Key('row1'),
                  label: '名称 Name',
                  helper: '用于识别设备 Used to identify the device',
                  child: IanvsTextField(key: Key('field1')),
                ),
                IanvsFieldRow(
                  key: const Key('row2'),
                  label: '类型 Type',
                  child: IanvsSelect(
                    key: const Key('field2'),
                    value: 'one',
                    options: const [IanvsOption('one', 'Local')],
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
            width: width,
            scale: scale,
          ),
        );
        final a = tester.getRect(find.byKey(const Key('field1')));
        final b = tester.getRect(find.byKey(const Key('field2')));
        expect(a.left, b.left);
        expect(a.width, b.width);
        expect(
          tester.getRect(find.byKey(const Key('row2'))).top -
              tester.getRect(find.byKey(const Key('row1'))).bottom,
          closeTo(12, .01),
        );
        final label = tester.getRect(find.text('名称 Name'));
        if (width < 480 || scale > 1.5) {
          expect(label.bottom, lessThan(a.top));
        } else {
          expect(label.right, lessThan(a.left));
          expect(label.top, lessThan(a.bottom));
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
