import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';
import 'compact_touch_test.dart' show compactTheme;

Size inputSurface(WidgetTester tester, String name) {
  final content = find
      .descendant(
        of: find.byKey(Key(name)),
        matching: find.byWidgetPredicate(
          (w) => w is EditableText || w is RichText,
        ),
      )
      .first;
  return InputDecorator.containerOf(tester.element(content))!.size;
}

void main() {
  for (final brightness in Brightness.values) {
    for (final scale in [1.0, 2.0, 3.0]) {
      testWidgets('single-line decoration heights agree $brightness / $scale', (
        tester,
      ) async {
        var clears = 0;
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
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const TextField(
                        key: Key('plain'),
                        decoration: InputDecoration(hintText: 'Value'),
                      ),
                      const TextField(
                        key: Key('prefix'),
                        decoration: InputDecoration(
                          hintText: 'Value',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      TextField(
                        key: const Key('suffix'),
                        decoration: InputDecoration(
                          hintText: 'Value',
                          suffixIcon: IconButton(
                            tooltip: 'Clear',
                            onPressed: () => clears++,
                            icon: const Icon(Icons.clear),
                          ),
                        ),
                      ),
                      TextFormField(
                        key: const Key('both'),
                        decoration: InputDecoration(
                          hintText: 'Value',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            tooltip: 'Show',
                            onPressed: () {},
                            icon: const Icon(Icons.visibility),
                          ),
                        ),
                      ),
                      Builder(
                        builder: (context) => InputDecorator(
                          key: const Key('decorator'),
                          decoration: const InputDecoration().applyDefaults(
                            Theme.of(context).inputDecorationTheme,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Value',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                      const IanvsTextField(
                        key: Key('ianvs'),
                        hintText: 'Value',
                      ),
                      IanvsSelect(
                        key: const Key('select'),
                        value: 'v',
                        options: const [IanvsOption('v', 'Value')],
                        onChanged: (_) {},
                      ),
                      const DropdownMenu(
                        key: Key('dropdown'),
                        initialSelection: 'v',
                        expandedInsets: EdgeInsets.zero,
                        dropdownMenuEntries: [
                          DropdownMenuEntry(value: 'v', label: 'Value'),
                        ],
                      ),
                      const TextField(
                        key: Key('helper-plain'),
                        decoration: InputDecoration(
                          hintText: 'Value',
                          helperText: 'Help',
                        ),
                      ),
                      const TextField(
                        key: Key('helper-prefix'),
                        decoration: InputDecoration(
                          hintText: 'Value',
                          helperText: 'Help',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                      const IanvsTextField(
                        key: Key('error-field'),
                        hintText: 'Value',
                        errorText: 'Help',
                      ),
                      IanvsSelect(
                        key: const Key('helper-select'),
                        value: 'v',
                        helperText: 'Help',
                        options: const [IanvsOption('v', 'Value')],
                        onChanged: (_) {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final heights = {
          for (final name in [
            'plain',
            'prefix',
            'suffix',
            'both',
            'decorator',
            'ianvs',
            'select',
          ])
            name: tester.getSize(find.byKey(Key(name))).height,
        };
        for (final entry in heights.entries) {
          expect(
            entry.value,
            closeTo(heights['plain']!, .5),
            reason: '$heights',
          );
          expect(
            entry.value,
            scale == 1 ? closeTo(48, .5) : greaterThan(48),
            reason: '$heights',
          );
        }
        for (final name in [
          'helper-plain',
          'helper-prefix',
          'error-field',
          'helper-select',
        ]) {
          expect(
            inputSurface(tester, name).height,
            closeTo(inputSurface(tester, 'plain').height, .5),
          );
          expect(inputSurface(tester, name).height, greaterThanOrEqualTo(48));
          expect(
            tester.getSize(find.byKey(Key(name))).height,
            greaterThan(inputSurface(tester, name).height),
          );
        }
        final clear = find.byTooltip('Clear');
        expect(tester.getSize(clear).shortestSide, greaterThanOrEqualTo(48));
        await tester.ensureVisible(clear);
        await tester.pumpAndSettle();
        await tester.tap(clear);
        await tester.pumpAndSettle();
        expect(clears, 1);
        // Flutter's DropdownMenu adds four points around its padded arrow.
        // Keep that target intact instead of clamping the arrow to 40 points.
        final dropdown = find.byKey(const Key('dropdown'));
        expect(
          tester.getSize(dropdown).height,
          scale == 1 ? closeTo(56, .5) : greaterThan(48),
        );
        final arrow = find.descendant(
          of: dropdown,
          matching: find.byType(IconButton),
        );
        expect(tester.getSize(arrow).shortestSide, greaterThanOrEqualTo(48));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'input minimum permits multiline growth and explicit host constraints',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: compactTheme(),
          home: const Scaffold(
            body: Column(
              children: [
                IanvsTextField(
                  key: Key('multiline'),
                  minLines: 3,
                  maxLines: null,
                ),
                IanvsTextField(
                  key: Key('custom'),
                  decoration: InputDecoration(
                    constraints: BoxConstraints(minHeight: 72),
                  ),
                ),
                TextField(
                  key: Key('raw-custom'),
                  decoration: InputDecoration(
                    constraints: BoxConstraints(minHeight: 72),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      expect(
        tester.getSize(find.byKey(const Key('multiline'))).height,
        greaterThan(48),
      );
      expect(tester.getSize(find.byKey(const Key('custom'))).height, 72);
      expect(tester.getSize(find.byKey(const Key('raw-custom'))).height, 72);
      expect(tester.takeException(), isNull);
    },
  );
}
