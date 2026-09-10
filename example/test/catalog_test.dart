import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';
import 'package:ianvs_design_gallery/main.dart';
import 'package:ianvs_design_gallery/gallery/catalog.dart';

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    for (final entry in entries) {
      for (final size in [const Size(1487, 1058), const Size(480, 800)]) {
        testWidgets('${entry.id} renders $mode at $size', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            GalleryApp(initialThemeMode: mode, initialPage: entry.id),
          );
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull);
          expect(find.text(entry.title), findsWidgets);
          await tester.pumpWidget(const SizedBox());
          await tester.pump();
        });
      }
    }
  }
  for (final entry in entries) {
    testWidgets('${entry.id} fits a narrow window at 200% text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(480, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(
        GalleryApp(initialPage: entry.id, initialDensity: IanvsDensity.touch),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets('mainstream Material families are real widgets in catalog', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1487, 1058);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final group in <String, List<Type>>{
      'actions': [
        FilledButton,
        ElevatedButton,
        OutlinedButton,
        TextButton,
        IconButton,
        FloatingActionButton,
        SegmentedButton<String>,
      ],
      'inputs': [
        TextFormField,
        SearchBar,
        Autocomplete<String>,
        DropdownMenu<String>,
        Checkbox,
        Radio<String>,
        Switch,
        Slider,
        RangeSlider,
        ActionChip,
        ChoiceChip,
        FilterChip,
        InputChip,
      ],
      'navigation': [
        AppBar,
        BottomAppBar,
        NavigationBar,
        NavigationRail,
        NavigationDrawer,
        TabBar,
        MenuBar,
        MenuAnchor,
      ],
      'feedback': [
        Badge,
        Tooltip,
        MaterialBanner,
        CircularProgressIndicator,
        LinearProgressIndicator,
        Card,
        ListTile,
        ExpansionTile,
        DataTable,
      ],
    }.entries) {
      await tester.pumpWidget(
        GalleryApp(key: ValueKey(group.key), initialPage: group.key),
      );
      await tester.pump(const Duration(milliseconds: 100));
      for (final type in group.value.where((t) => t != MaterialBanner)) {
        expect(
          type == SearchAnchor
              ? find.byWidgetPredicate((w) => w is SearchAnchor)
              : find.byType(type),
          findsWidgets,
          reason: '${group.key} must render $type',
        );
      }
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
