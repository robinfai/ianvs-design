import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

ThemeData compactTheme([Brightness brightness = Brightness.light]) =>
    IanvsTheme.build(
      platform: TargetPlatform.iOS,
      brightness: brightness,
      density: IanvsDensity.touch,
      touchVisualDensity: IanvsTouchVisualDensity.compact,
    );

void main() {
  test(
    'visual compactness preserves touch input and default platform metrics',
    () {
      final theme = compactTheme();
      final t = theme.extension<IanvsTokens>()!;
      expect(t.density, IanvsDensity.touch);
      expect(t.isCompactTouch, isTrue);
      expect(t.controlHeight, 44);
      expect(t.rowHeight, 48);
      expect(theme.materialTapTargetSize, MaterialTapTargetSize.padded);
      expect(theme.visualDensity, VisualDensity.standard);
      expect(theme.textTheme.titleLarge!.fontSize, 18);
      expect(theme.textTheme.titleMedium!.fontSize, 17);
      expect(theme.textTheme.bodyLarge!.fontSize, 16);
      expect(theme.textTheme.bodyMedium!.fontSize, 16);
      expect(theme.textTheme.bodySmall!.fontSize, 13);
      expect(theme.textTheme.labelMedium!.fontSize, 13);
      expect(theme.iconTheme.size, 20);
      expect(t.copyWith(accent: Colors.red).isCompactTouch, isTrue);
      final standard = IanvsTheme.build(
        platform: TargetPlatform.iOS,
        density: IanvsDensity.touch,
      );
      final middle = ThemeData.lerp(
        standard,
        theme,
        .5,
      ).extension<IanvsTokens>()!;
      expect(middle.controlHeight, 46);
      expect(middle.rowHeight, 52);
      expect(middle.density, IanvsDensity.touch);
      expect(middle.touchVisualDensity, IanvsTouchVisualDensity.compact);
      for (final platform in [
        TargetPlatform.iOS,
        TargetPlatform.android,
        TargetPlatform.macOS,
      ]) {
        for (final density in IanvsDensity.values) {
          final original = IanvsTheme.build(
            platform: platform,
            density: density,
          );
          final explicit = IanvsTheme.build(
            platform: platform,
            density: density,
            touchVisualDensity: IanvsTouchVisualDensity.standard,
          );
          expect(explicit.textTheme, original.textTheme);
          expect(
            explicit.extension<IanvsTokens>()!.controlHeight,
            density == IanvsDensity.touch
                ? 48
                : density == IanvsDensity.compact
                ? 32
                : 40,
          );
          if (density != IanvsDensity.touch) {
            final ignored = IanvsTheme.build(
              platform: platform,
              density: density,
              touchVisualDensity: IanvsTouchVisualDensity.compact,
            );
            expect(ignored.textTheme, original.textTheme);
            expect(ignored.extension<IanvsTokens>()!.isCompactTouch, isFalse);
            expect(
              ignored.extension<IanvsTokens>()!.controlHeight,
              original.extension<IanvsTokens>()!.controlHeight,
            );
          }
        }
      }
    },
  );

  for (final brightness in Brightness.values) {
    for (final size in [
      const Size(375, 844),
      const Size(402, 844),
      const Size(844, 375),
    ]) {
      for (final scale in [1.0, 2.0, 3.0]) {
        testWidgets(
          'compact form grows at $size / $scale / $brightness (402 has keyboard)',
          (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1;
            if (size.width == 402) {
              tester.view.viewInsets = const FakeViewPadding(bottom: 300);
              addTearDown(tester.view.resetViewInsets);
            }
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            final controller = TextEditingController();
            addTearDown(controller.dispose);
            var saves = 0;
            await tester.pumpWidget(
              MaterialApp(
                theme: compactTheme(brightness),
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: Scaffold(
                  body: SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: IanvsFormSection(
                          title: const Text('设备设置 Device settings'),
                          trailing: IanvsButton(
                            onPressed: () {},
                            child: const Text('恢复所有默认设置 Restore all defaults'),
                          ),
                          spacing: 12,
                          children: [
                            IanvsFieldRow(
                              label: '设备名称 Device name',
                              child: IanvsTextField(
                                key: const Key('field'),
                                controller: controller,
                              ),
                            ),
                            const IanvsFieldRow(
                              label: '说明 Description',
                              child: IanvsTextField(
                                key: Key('error'),
                                errorText:
                                    '请检查输入的完整地址 Please check the complete address',
                              ),
                            ),
                            IanvsFieldRow(
                              label: '密码 Password',
                              child: IanvsTextField(
                                key: const Key('password'),
                                suffixIcon: IanvsIconButton(
                                  icon: Icons.visibility,
                                  tooltip: '显示密码',
                                  onPressed: () {},
                                ),
                              ),
                            ),
                            ListTile(
                              key: const Key('row'),
                              title: const Text('设备 Device'),
                              onTap: () {},
                            ),
                            ListTile(
                              title: const Text(
                                '同步所有已连接设备 Synchronize all connected devices',
                              ),
                              onTap: () {},
                            ),
                            IanvsButton(
                              key: const Key('save'),
                              onPressed: () => saves++,
                              child: const Text(
                                '保存并同步所有设备 Save and synchronize all devices',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            await tester.pump();
            expect(tester.takeException(), isNull);
            final label = find.text('设备名称 Device name');
            final field = find.byKey(const Key('field'));
            if (size.width < 480 || scale > 1.5) {
              expect(
                DefaultTextStyle.of(tester.element(label)).style.fontSize,
                13,
              );
              expect(
                tester.getRect(field).top - tester.getRect(label).bottom,
                closeTo(4, .01),
              );
            } else {
              expect(
                tester.getRect(field).left,
                greaterThan(tester.getRect(label).right),
              );
            }
            expect(tester.getSize(field).height, greaterThanOrEqualTo(44));
            expect(
              tester.getSize(find.byKey(const Key('password'))).height,
              greaterThanOrEqualTo(48),
            );
            expect(
              tester.getSize(find.byKey(const Key('row'))).height,
              greaterThanOrEqualTo(48),
            );
            if (scale == 1) {
              expect(tester.getSize(field).height, lessThanOrEqualTo(48));
              expect(
                tester.getSize(find.byKey(const Key('row'))).height,
                closeTo(48, .01),
              );
            } else {
              expect(tester.getSize(field).height, greaterThan(48));
              expect(
                tester.getSize(find.byKey(const Key('row'))).height,
                greaterThan(48),
              );
            }
            await tester.ensureVisible(field);
            await tester.enterText(field, 'New device');
            await tester.pumpAndSettle();
            expect(controller.text, 'New device');
            final save = find.byKey(const Key('save'));
            await tester.ensureVisible(save);
            await tester.pumpAndSettle();
            expect(
              tester.getCenter(save).dy,
              lessThan(size.height - (size.width == 402 ? 300 : 0)),
            );
            await tester.tap(save);
            await tester.pumpAndSettle();
            expect(saves, 1);
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    testWidgets(
      'compact visual bounds retain padded actions and semantics $brightness',
      (tester) async {
        final semantics = tester.ensureSemantics();
        var steps = 0;
        String? selected;
        await tester.pumpWidget(
          MaterialApp(
            theme: compactTheme(brightness),
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IanvsButton(
                      key: const Key('button'),
                      onPressed: () {},
                      child: const Text('Save'),
                    ),
                    IanvsIconButton(
                      icon: Icons.add,
                      tooltip: 'Add',
                      onPressed: () {},
                    ),
                    IanvsNumberStepper(
                      value: 1,
                      label: 'Count',
                      onChanged: (value) => steps = value,
                    ),
                    IanvsControlLabel(
                      label: 'Backups',
                      onTap: () {},
                      controlBuilder: (focus) => Checkbox(
                        value: true,
                        focusNode: focus,
                        onChanged: (_) {},
                      ),
                    ),
                    IanvsSettingsRow(
                      title: 'Sync',
                      value: true,
                      onChanged: (_) {},
                    ),
                    IanvsSelect(
                      value: 'a',
                      labelText: 'Location',
                      options: const [
                        IanvsOption('a', 'Personal'),
                        IanvsOption('b', 'Work'),
                      ],
                      onChanged: (value) => selected = value,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final button = find.byKey(const Key('button'));
        final paint = find
            .descendant(of: button, matching: find.byType(Material))
            .first;
        expect(tester.getSize(paint).height, 44);
        expect(tester.getSize(button).height, 48);
        final icon = find.byIcon(Icons.add).first;
        expect(IconTheme.of(tester.element(icon)).size, 20);
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await tester.tap(find.byTooltip('增加 Count'));
        await tester.pumpAndSettle();
        expect(steps, 2);
        await tester.tap(find.byType(IanvsSelect<String>));
        await tester.pumpAndSettle();
        for (final element in find.byType(MenuItemButton).evaluate()) {
          expect(
            tester.getSize(find.byWidget(element.widget)).height,
            greaterThanOrEqualTo(48),
          );
        }
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
        await tester.tap(find.text('Work').last);
        await tester.pumpAndSettle();
        expect(selected, 'b');
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }
}
