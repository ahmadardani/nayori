import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nayori/main.dart';

void main() {
  testWidgets('Nayori App smoke test', (WidgetTester tester) async {

    await tester.pumpWidget(const NayoriApp());

    expect(find.text('SEARCH'), findsOneWidget);
    expect(find.text('ALL KANJI'), findsOneWidget);
    
    expect(find.text('0'), findsNothing);
  });
}