import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';
import 'package:ianvs_design_gallery/main.dart';

void main() {
  for (final size in [const Size(1487, 1058), const Size(480, 800)]) {
    testWidgets(
      'both input dropdowns share responsive field columns at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const GalleryApp(initialPage: 'inputs'));
        await tester.pumpAndSettle();
        final select = tester.getRect(find.byType(IanvsSelect<String>));
        final dropdown = tester.getRect(find.byType(DropdownMenu<String>));
        expect(select.left, dropdown.left);
        expect(select.right, dropdown.right);
        expect(select.height, closeTo(dropdown.height, 1));
        expect(dropdown.top, greaterThan(select.bottom));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('connection validates and saves local draft', (tester) async {
    tester.view.physicalSize = const Size(1487, 1058);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const GalleryApp());
    await tester.pump(const Duration(milliseconds: 250));
    final command = find.descendant(
      of: find.byKey(const ValueKey('connection-command')),
      matching: find.byType(TextFormField),
    );
    await tester.enterText(command, '');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('connection-save')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('请输入启动命令'), findsNWidgets(2));
    await tester.enterText(command, '/bin/bash');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('connection-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('所有更改已保存'), findsOneWidget);
    await tester.enterText(command, '/bin/fish');
    await tester.pump();
    await tester.tap(find.text('取消'));
    await tester.pump();
    expect(tester.widget<TextFormField>(command).controller!.text, '/bin/bash');
    expect(find.text('所有更改已保存'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'scenario changes clear stale validation and compare saved values',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const GalleryApp());
      await tester.pumpAndSettle();
      final command = find.descendant(
        of: find.byKey(const ValueKey('connection-command')),
        matching: find.byType(TextFormField),
      );
      expect(find.text('所有更改已保存'), findsOneWidget);
      await tester.enterText(command, '');
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('connection-save')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(Form), matching: find.text('请输入启动命令')),
        findsOneWidget,
      );
      await tester.tap(find.text('ACP'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextFormField>(command).controller!.text, 'npx');
      expect(
        find.descendant(of: find.byType(Form), matching: find.text('请输入启动命令')),
        findsNothing,
      );
      expect(find.text('有未保存的更改'), findsOneWidget);
      await tester.tap(find.text('Terminal'));
      await tester.pumpAndSettle();
      expect(find.text('所有更改已保存'), findsOneWidget);
      await tester.tap(find.text('通用'));
      await tester.pumpAndSettle();
      expect(find.text('所有更改已保存'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final size in [const Size(1440, 1000), const Size(480, 900)]) {
    testWidgets(
      'save actions stay visible while the connection form scrolls at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(
          const GalleryApp(initialDensity: IanvsDensity.touch),
        );
        await tester.pumpAndSettle();
        final actions = find.byKey(const ValueKey('connection-actions'));
        final before = tester.getRect(actions);
        expect(before.top, greaterThan(0));
        expect(before.bottom, lessThan(size.height));
        final command = find.byKey(const ValueKey('connection-command'));
        await tester.drag(command, const Offset(0, -450));
        await tester.pumpAndSettle();
        expect(tester.getRect(actions), before);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'empty catalog feedback appears beside the search and clears it',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const GalleryApp());
      await tester.pumpAndSettle();
      final search = find.widgetWithText(TextFormField, '搜索组件');
      await tester.enterText(search, 'nothing-matches');
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('没有匹配的组件')).dy -
            tester.getBottomLeft(search).dy,
        lessThan(60),
      );
      await tester.tap(find.text('清空搜索'));
      await tester.pumpAndSettle();
      expect(find.text('没有匹配的组件'), findsNothing);
      expect(find.text('按钮'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
