import 'package:flutter_test/flutter_test.dart';
import 'package:ianvs_design/ianvs_design.dart';

void main() {
  testWidgets(
    'host proxy can share controller, focus, callbacks and form state',
    (tester) async {
      final controller = TextEditingController(text: 'initial');
      final focus = FocusNode();
      final form = GlobalKey<FormState>();
      final changes = <String>[];
      String? saved;
      addTearDown(controller.dispose);
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        MaterialApp(
          theme: IanvsTheme.light(),
          home: Scaffold(
            body: Form(
              key: form,
              child: Semantics(
                label: 'Host input name',
                child: IanvsTextField(
                  controller: controller,
                  focusNode: focus,
                  onChanged: changes.add,
                  onSaved: (value) => saved = value,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                ),
              ),
            ),
          ),
        ),
      );
      focus.requestFocus();
      await tester.pump();
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.controller, same(controller));
      expect(editable.focusNode, same(focus));
      expect(focus.hasFocus, isTrue);
      await tester.enterText(find.byType(TextFormField), 'typed');
      expect(changes, ['typed']);
      // A native proxy updates the shared controller and calls the host callback.
      controller.text = 'from native proxy';
      changes.add(controller.text);
      await tester.pump();
      expect(find.text('from native proxy'), findsOneWidget);
      form.currentState!.save();
      expect(saved, 'from native proxy');
      controller.clear();
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('Required'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      expect(() => controller.text = 'still owned by host', returnsNormally);
      expect(() => focus.addListener(() {}), returnsNormally);
    },
  );
}
