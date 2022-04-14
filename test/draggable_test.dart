import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:posapp/common/draggable_widget/draggable_widget.dart';

void main() {
  final overlayCtnKey = GlobalKey();
  final btnKey = GlobalKey();
  const fab = SizedBox(width: 100, height: 100, child: Text("123"));
  final positionedDraggable = DraggableWidget(key: btnKey, child: fab);
  final stack = Stack(children: [Container(key: overlayCtnKey), positionedDraggable]);

  testWidgets(
    'Should be able to drag the widget',
    (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: stack),
      ));
      await tester.drag(find.byWidget(fab), const Offset(300.0, 300.0));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      final rb = btnKey.currentState!.context.findRenderObject()! as RenderBox;
      var globalOffset = rb.localToGlobal(Offset.zero);
      expect(globalOffset, equals(const Offset(300, 300)));
    },
  );
}
