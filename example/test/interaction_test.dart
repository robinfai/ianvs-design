import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';
import 'package:ianvs_design_gallery/main.dart';

Future<void> open(WidgetTester tester, String page, ThemeMode mode) async {
  tester.view.physicalSize = const Size(1487, 1058);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    GalleryApp(initialPage: page, initialThemeMode: mode),
  );
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
}

void main() {
  testWidgets('storage choice tiles update the shared radio group', (
    tester,
  ) async {
    await open(tester, 'feedback', ThemeMode.light);
    await tapVisible(tester, find.text('远程存储'));
    expect(
      tester
          .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
          .groupValue,
      '远程',
    );
    final selected = find.widgetWithText(IanvsChoiceTile<String>, '远程存储');
    expect(
      find.descendant(of: selected, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('归档存储'));
    expect(
      tester
          .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
          .groupValue,
      '远程',
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('choice labels share checkbox, radio and switch behavior', (
    tester,
  ) async {
    await open(tester, 'inputs', ThemeMode.dark);
    Finder labelled(String text) => find.byWidgetPredicate(
      (widget) => widget is IanvsControlLabel && widget.label == text,
    );
    Finder labelText(String text) => find.descendant(
      of: labelled(text),
      matching: find.byType(SelectableText),
    );
    bool? checkValue(String text) => tester
        .widget<Checkbox>(
          find.descendant(of: labelled(text), matching: find.byType(Checkbox)),
        )
        .value;

    Future<void> tapChoice(Finder finder) async {
      await Scrollable.ensureVisible(tester.element(finder), alignment: 0.5);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
    }

    final initial = checkValue('复选框');
    await tapChoice(labelText('复选框'));
    expect(checkValue('复选框'), !initial!);
    await tapChoice(labelText('Material Switch'));
    expect(checkValue('复选框'), initial);
    await tapChoice(labelText('恢复工作区'));
    expect(checkValue('复选框'), !initial);

    // The label follows Flutter's native null -> false -> true -> null cycle.
    for (final expected in <bool?>[false, true, null]) {
      await tapChoice(labelText('三态选择'));
      expect(checkValue('三态选择'), expected);
    }
    for (final expected in <bool?>[false, true, null]) {
      await tapChoice(
        find.descendant(of: labelled('三态选择'), matching: find.byType(Checkbox)),
      );
      expect(checkValue('三态选择'), expected);
    }
    for (final value in ['远程', '本地']) {
      await tapChoice(labelText(value));
      expect(
        tester
            .widget<RadioGroup<String>>(find.byType(RadioGroup<String>))
            .groupValue,
        value,
      );
    }
    await tapChoice(labelText('禁用'));
    await tapChoice(labelText('禁用开关'));
    expect(checkValue('禁用'), isFalse);
    expect(
      tester
          .widget<Switch>(
            find.descendant(
              of: labelled('禁用开关'),
              matching: find.byType(Switch),
            ),
          )
          .value,
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('input chip can be selected, deleted and restored', (
    tester,
  ) async {
    await open(tester, 'inputs', ThemeMode.light);
    await tapVisible(tester, find.byType(InputChip));
    expect(tester.widget<InputChip>(find.byType(InputChip)).selected, isTrue);
    await tapVisible(tester, find.byTooltip('删除'));
    expect(find.byType(InputChip), findsNothing);
    await tapVisible(tester, find.text('恢复标签'));
    expect(find.byType(InputChip), findsOneWidget);
  });
  testWidgets(
    'copy sample sends the selected Dart example to the platform clipboard',
    (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await open(tester, 'supplements', ThemeMode.dark);
      await tapVisible(tester, find.text('复制示例'));
      expect(copied, startsWith('IanvsNumberStepper('));
      expect(copied, contains('onChanged:'));
      expect(find.text('示例代码已复制'), findsOneWidget);
    },
  );
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('date, range and time routes use $mode and return results', (
      tester,
    ) async {
      await open(tester, 'inputs', mode);
      for (final spec in <(String, Type)>[
        ('日期 9/10', DatePickerDialog),
        ('范围 9/10 – 9/14', DateRangePickerDialog),
        ('时间 09:30', TimePickerDialog),
      ]) {
        final trigger = spec.$2 == TimePickerDialog
            ? find.textContaining('时间 ').last
            : find.text(spec.$1);
        await tapVisible(tester, trigger);
        final dialog = find.byType(spec.$2);
        expect(dialog, findsOneWidget);
        expect(
          Theme.of(tester.element(dialog)).brightness,
          mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
        );
        expect(tester.takeException(), isNull);
        // Confirm exercises the route's typed result rather than a static preview.
        await tapVisible(
          tester,
          find.text(spec.$2 == DateRangePickerDialog ? '保存' : '确定').last,
        );
        expect(dialog, findsNothing);
      }
    });
    testWidgets('dialogs protect draft and sheet returns a selection $mode', (
      tester,
    ) async {
      await open(tester, 'overlays', mode);
      final draft = find.widgetWithText(TextFormField, '草稿名称');
      await tester.enterText(draft, 'keep me');
      await tapVisible(tester, find.text('尝试退出'));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.widget<TextFormField>(draft).controller!.text, 'keep me');
      await tapVisible(tester, find.text('尝试退出'));
      await tapVisible(tester, find.text('放弃更改').last);
      expect(tester.widget<TextFormField>(draft).controller!.text, isEmpty);
      await tapVisible(tester, find.text('SimpleDialog'));
      await tapVisible(tester, find.text('Shell'));
      expect(find.textContaining('已选择 Shell'), findsWidgets);
      await tapVisible(tester, find.text('打开底部面板'));
      await tapVisible(tester, find.text('空白项目'));
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.textContaining('空白项目'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('theme, density and search update actual catalog', (
    tester,
  ) async {
    await open(tester, 'connection', ThemeMode.dark);
    await tapVisible(tester, find.byTooltip('外观模式'));
    await tapVisible(tester, find.widgetWithText(MenuItemButton, '浅色'));
    await tester.pumpAndSettle();
    final field = find.byKey(const ValueKey('connection-name'));
    expect(Theme.of(tester.element(field)).brightness, Brightness.light);
    await tapVisible(tester, find.text('紧凑').first);
    await tapVisible(tester, find.widgetWithText(MenuItemButton, '触控'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(field)).extension<IanvsTokens>()!.controlHeight,
      48,
    );
    await tester.sendKeyDownEvent(LogicalKeyboardKey.metaLeft);
    await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.metaLeft);
    await tester.pump();
    await tester.pump();
    final search = find.widgetWithText(TextFormField, '搜索组件');
    expect(
      tester
          .widget<TextField>(
            find.descendant(of: search, matching: find.byType(TextField)),
          )
          .focusNode!
          .hasFocus,
      isTrue,
    );
    await tester.enterText(search, 'button');
    await tester.pump();
    await tapVisible(tester, find.text('按钮').first);
    expect(find.text('填充按钮'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Material banner, anchored menu and tabs perform actions', (
    tester,
  ) async {
    await open(tester, 'feedback', ThemeMode.dark);
    await tapVisible(tester, find.text('显示 MaterialBanner'));
    expect(find.byType(MaterialBanner), findsOneWidget);
    await tapVisible(tester, find.text('知道了'));
    expect(find.byType(MaterialBanner), findsNothing);
    await tapVisible(tester, find.text('导航').first);
    await tapVisible(tester, find.text('打开锚定菜单'));
    await tapVisible(tester, find.text('复制路径').last);
    expect(find.textContaining('已复制路径'), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
