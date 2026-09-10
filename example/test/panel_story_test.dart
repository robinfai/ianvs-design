import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';
import 'package:ianvs_design_gallery/gallery/panel_story.dart';

void main() {
  testWidgets('panel resizing, hiding and narrow layout retain the draft', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        theme: IanvsTheme.dark(),
        home: const Scaffold(body: SingleChildScrollView(child: PanelStory())),
      ),
    );
    await tester.enterText(find.byType(TextFormField), 'Keep this draft');
    await tester.drag(
      find.byKey(const Key('example-sidebar-handle')),
      const Offset(60, 0),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const Key('resizable-sidebar'))).width,
      greaterThan(160),
    );
    await tester.drag(
      find.byKey(const Key('example-terminal-handle')),
      const Offset(0, -40),
    );
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const Key('resizable-terminal'))).height,
      greaterThan(90),
    );
    await tester.tap(find.text('隐藏示例侧栏'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('resizable-sidebar')), findsNothing);
    expect(find.text('Keep this draft'), findsOneWidget);
    await tester.tap(find.text('显示示例侧栏'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(400, 700);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('resizable-sidebar')), findsNothing);
    expect(find.text('Keep this draft'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
