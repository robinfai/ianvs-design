import 'dart:ui' show BoxHeightStyle;

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:ianvs_design/ianvs_design.dart';
import 'package:ianvs_design_gallery/main.dart';

void main() {
  testWidgets('large text keeps a long date and weekday intact', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final font = FontLoader('GallerySans')
      ..addFont(rootBundle.load('assets/fonts/NotoSansSC.ttf'));
    await font.load();
    await tester.pumpWidget(const GalleryApp(initialPage: 'inputs'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('日期 9/10'));
    await tester.tap(find.text('日期 9/10'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('切换到输入模式'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(
        of: find.byType(DatePickerDialog),
        matching: find.byType(TextField),
      ),
      '2026/12/31',
    );
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('日期 12/31'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('切换到输入模式'));
    await tester.pumpAndSettle();
    final header = find.byWidgetPredicate(
      (w) => w is Text && (w.data?.startsWith('1\u20602\u2060月') ?? false),
    );
    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(of: header, matching: find.byType(RichText)),
    );
    expect(paragraph.didExceedMaxLines, isFalse);
    final dateEnd = paragraph.text.toPlainText().indexOf('日') + 1;
    final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: dateEnd),
      boxHeightStyle: BoxHeightStyle.max,
    );
    expect(boxes.map((box) => box.top).toSet(), hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text range input keeps both dates visible', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 720);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final font = FontLoader('GallerySans')
      ..addFont(rootBundle.load('assets/fonts/NotoSansSC.ttf'));
    await font.load();
    await tester.pumpWidget(const GalleryApp(initialPage: 'inputs'));
    await tester.pumpAndSettle();
    final trigger = find.text('范围 9/10 – 9/14');
    await tester.ensureVisible(trigger);
    await tester.tap(trigger);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('切换到输入模式'));
    await tester.pumpAndSettle();
    final header = find.byWidgetPredicate(
      (w) =>
          w is Text &&
          (w.data?.contains('\u2060') ?? false) &&
          (w.data?.contains(' – ') ?? false),
    );
    expect(header, findsOneWidget);
    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(of: header, matching: find.byType(RichText)),
    );
    expect(paragraph.didExceedMaxLines, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving a story dismisses its pending action message', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const GalleryApp(initialPage: 'feedback'));
    await tester.pump();
    await tester.tap(find.text('显示 Snackbar'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.tap(find.text('工作区'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('pointer interaction dismisses the previous independent menu', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const GalleryApp(initialPage: 'navigation'));
    await tester.pumpAndSettle();
    final quick = find.widgetWithText(OutlinedButton, '快捷菜单');
    final file = find.widgetWithText(SubmenuButton, '文件');
    await tester.ensureVisible(file);
    await tester.pumpAndSettle();
    await tester.tap(quick);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(MenuItemButton, '重命名'), findsOneWidget);
    await tester.tap(file);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(MenuItemButton, '重命名'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  for (final width in [1440.0, 480.0]) {
    testWidgets(
      'drawer indicator encloses each selected destination at $width',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const GalleryApp(initialPage: 'navigation'));
        await tester.pumpAndSettle();
        final drawer = find.byType(NavigationDrawer);
        await tester.ensureVisible(drawer);
        await tester.pumpAndSettle();
        for (final label in ['主页', '项目', '设置']) {
          final destination = find.descendant(
            of: drawer,
            matching: find.text(label),
          );
          await tester.tap(destination);
          await tester.pumpAndSettle();
          final index = ['主页', '项目', '设置'].indexOf(label);
          final indicators = find.descendant(
            of: drawer,
            matching: find.byType(NavigationIndicator),
          );
          final indicator = tester.getRect(indicators.at(index));
          expect(indicator.contains(tester.getCenter(destination)), isTrue);
          final icons = find.descendant(
            of: drawer,
            matching: find.byType(Icon),
          );
          expect(indicator.contains(tester.getCenter(icons.at(index))), isTrue);
          expect(
            indicator.width,
            greaterThan(tester.getSize(drawer).width - 30),
          );
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets('narrow workspace menu selects a named destination', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(480, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const GalleryApp(initialPage: 'workspace'));
    await tester.pumpAndSettle();
    final trigger = find.byTooltip('选择工作区内容');
    await tester.ensureVisible(trigger);
    await tester.tap(trigger);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, '设置'));
    await tester.pumpAndSettle();
    expect(find.text('项目设置'), findsOneWidget);
    expect(
      find.descendant(of: trigger, matching: find.text('设置')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
