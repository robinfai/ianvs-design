import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

void main() {
  test(
    'iOS touch uses semantic type sizes and Flutter Cupertino font families',
    () {
      final theme = IanvsTheme.build(
        platform: TargetPlatform.iOS,
        density: IanvsDensity.touch,
      );
      expect(theme.textTheme.bodyLarge!.fontSize, 17);
      expect(theme.textTheme.bodyMedium!.fontSize, 17);
      expect(theme.textTheme.bodySmall!.fontSize, 15);
      expect(theme.textTheme.labelLarge!.fontSize, 17);
      expect(theme.textTheme.labelMedium!.fontSize, 15);
      expect(theme.textTheme.labelSmall!.fontSize, 13);
      expect(theme.inputDecorationTheme.helperStyle!.fontSize, 13);
      expect(theme.inputDecorationTheme.errorStyle!.fontSize, 13);
      expect(
        theme.textTheme.bodyMedium!.fontFamily,
        Typography.blackCupertino.bodyMedium!.fontFamily,
      );
      expect(
        theme.textTheme.titleLarge!.fontFamily,
        Typography.blackCupertino.titleLarge!.fontFamily,
      );
      final custom = IanvsTheme.build(
        platform: TargetPlatform.iOS,
        density: IanvsDensity.touch,
        fontFamily: 'HostFont',
        fontFamilyFallback: const ['HostFallback'],
      );
      expect(custom.textTheme.bodyMedium!.fontFamily, 'HostFont');
      expect(custom.textTheme.titleLarge!.fontFamily, 'HostFont');
      expect(custom.textTheme.bodyMedium!.fontFamilyFallback, ['HostFallback']);
      final desktop = IanvsTheme.build(platform: TargetPlatform.macOS);
      expect(desktop.textTheme.bodyMedium!.fontSize, 13);
      expect(desktop.textTheme.bodySmall!.fontSize, 12);
      expect(desktop.textTheme.bodyMedium!.fontFamily, '.AppleSystemUIFont');
      expect(desktop.extension<IanvsTokens>()!.controlHeight, 32);
      final android = IanvsTheme.build(
        platform: TargetPlatform.android,
        density: IanvsDensity.touch,
      );
      expect(android.textTheme.bodyMedium!.fontSize, 16);
      expect(android.extension<IanvsTokens>()!.controlHeight, 48);
    },
  );

  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0, 3.0]) {
      testWidgets(
        'long form grows and actions remain usable $brightness $scale',
        (tester) async {
          tester.view.physicalSize = const Size(390, 844);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var actions = 0;
          late double scaledBody;
          await tester.pumpWidget(
            MaterialApp(
              theme: IanvsTheme.build(
                platform: TargetPlatform.iOS,
                density: IanvsDensity.touch,
                brightness: brightness,
              ),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    scaledBody = MediaQuery.textScalerOf(context).scale(17);
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: IanvsFormSection(
                          title: const Text(
                            '设备与远程同步设置 Devices and synchronization',
                            key: Key('heading'),
                          ),
                          trailing: IanvsButton(
                            key: const Key('trailing'),
                            onPressed: () => actions++,
                            child: const Text(
                              '恢复所有设备的默认设置 Restore defaults for all devices',
                            ),
                          ),
                          children: [
                            const IanvsFieldRow(
                              label: '远程设备名称 Remote device name',
                              child: IanvsTextField(
                                key: Key('field'),
                                helperText:
                                    '此名称会显示在同步设备列表中。Shown in the device list.',
                              ),
                            ),
                            IanvsSettingsRow(
                              title:
                                  '自动同步所有已连接设备 Automatically sync connected devices',
                              value: true,
                              onChanged: (_) {},
                            ),
                            IanvsButton(
                              key: const Key('save'),
                              icon: Icons.save,
                              onPressed: () => actions++,
                              child: const Text('保存并同步 Save and sync'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(scaledBody, 17 * scale);
          final heading = tester.getRect(find.byKey(const Key('heading')));
          final trailing = tester.getRect(find.byKey(const Key('trailing')));
          expect(trailing.top, greaterThanOrEqualTo(heading.bottom + 8));
          expect(trailing.left, greaterThanOrEqualTo(16));
          expect(trailing.right, lessThanOrEqualTo(374));
          for (final key in ['trailing', 'field', 'save']) {
            final size = tester.getSize(find.byKey(Key(key)));
            expect(size.width, greaterThanOrEqualTo(44));
            expect(size.height, greaterThanOrEqualTo(48));
          }
          await tester.ensureVisible(find.byKey(const Key('save')));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const Key('save')));
          await tester.pumpAndSettle();
          expect(actions, 1);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets(
      'touch targets include icon, switch, checkbox, select and menu $brightness',
      (tester) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(
          MaterialApp(
            theme: IanvsTheme.build(
              platform: TargetPlatform.iOS,
              density: IanvsDensity.touch,
              brightness: brightness,
            ),
            home: Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IanvsIconButton(
                        icon: Icons.add,
                        tooltip: 'Add device',
                        onPressed: () {},
                      ),
                      IanvsControlLabel(
                        label: 'Enable backups',
                        onTap: () {},
                        controlBuilder: (focus) => Checkbox(
                          value: true,
                          focusNode: focus,
                          onChanged: (_) {},
                        ),
                      ),
                      IanvsSettingsRow(
                        title: 'Sync devices',
                        value: true,
                        onChanged: (_) {},
                      ),
                      IanvsSelect(
                        value: 'a',
                        options: const [
                          IanvsOption('a', 'Personal'),
                          IanvsOption('b', 'Work'),
                        ],
                        onChanged: (_) {},
                        labelText: 'Location',
                      ),
                      ListTile(
                        title: const Text('Connected device'),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(
          tester.getSize(find.byType(IconButton)).shortestSide,
          greaterThanOrEqualTo(44),
        );
        expect(
          tester.getSize(find.byType(Switch)).shortestSide,
          greaterThanOrEqualTo(44),
        );
        expect(
          tester.getSize(find.byType(Checkbox)).shortestSide,
          greaterThanOrEqualTo(44),
        );
        expect(
          tester.getSize(find.byType(ListTile)).height,
          greaterThanOrEqualTo(56),
        );
        await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
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
        expect(tester.takeException(), isNull);
        semantics.dispose();
      },
    );
  }

  testWidgets(
    'dialog actions are reachable on a narrow screen above the keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          theme: IanvsTheme.build(
            platform: TargetPlatform.iOS,
            density: IanvsDensity.touch,
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => FilledButton(
                onPressed: () async {
                  result = await showIanvsConfirmDialog(
                    context: context,
                    title: '保存设置 Save settings',
                    message: '将更改应用到已连接设备。Apply changes to connected devices.',
                    confirmLabel: '保存 Save',
                    cancelLabel: '取消 Cancel',
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final cancel = find.text('取消 Cancel');
      await tester.ensureVisible(cancel);
      await tester.pumpAndSettle();
      expect(tester.getRect(cancel).bottom, lessThanOrEqualTo(544));
      await tester.tap(cancel);
      await tester.pumpAndSettle();
      expect(result, false);
    },
  );

  testWidgets('compact desktop keeps short header action beside its title', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: IanvsTheme.build(platform: TargetPlatform.macOS),
        home: Scaffold(
          body: IanvsFormSection(
            title: const Text('Settings', key: Key('title')),
            trailing: IanvsIconButton(
              icon: Icons.add,
              tooltip: 'Add',
              onPressed: () {},
            ),
            children: const [Text('Content')],
          ),
        ),
      ),
    );
    expect(
      tester.getTopLeft(find.byKey(const Key('title'))).dy,
      tester.getTopLeft(find.byType(IanvsIconButton)).dy,
    );
    expect(tester.takeException(), isNull);
  });
}
