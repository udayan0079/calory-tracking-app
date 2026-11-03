import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cta/main.dart';

void main() {
  testWidgets('Calorie Tracker initial screen elements test', (WidgetTester tester) async {
    await tester.pumpWidget(const CalorieTrackerApp());

    // 1. App name
    expect(find.text('Calorie Tracker'), findsOneWidget);

    // 2. Today's Date
    expect(find.textContaining("Today's Date:"), findsOneWidget);

    // 3. Three Summary Cards
    expect(find.text('Total Calories'), findsOneWidget);
    expect(find.text('Daily Goal'), findsOneWidget);
    expect(find.text('Remaining'), findsOneWidget);

    // Initial values
    expect(find.text('0 kcal'), findsOneWidget); // Total calories
    expect(find.text('2000 kcal'), findsNWidgets(2)); // Daily Goal and Remaining

    // 4. Empty food list message
    expect(find.text('No food items added yet.'), findsOneWidget);

    // 5. Add Food buttons
    expect(find.text('Add Food'), findsWidgets);
  });

  testWidgets('Add food validation and list update test', (WidgetTester tester) async {
    await tester.pumpWidget(const CalorieTrackerApp());

    // Tap FloatingActionButton
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify dialog opened
    expect(find.byType(AlertDialog), findsOneWidget);

    // Attempt to submit empty form
    final addButtonInDialog = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(ElevatedButton, 'Add Food'),
    );
    await tester.tap(addButtonInDialog);
    await tester.pumpAndSettle();

    // Verify validation errors
    expect(find.text('Please enter food name'), findsOneWidget);
    expect(find.text('Please enter calorie amount'), findsOneWidget);

    // Test invalid calorie input (negative number)
    final foodNameField = find.widgetWithText(TextFormField, 'Food Name');
    final calorieField = find.widgetWithText(TextFormField, 'Calorie Amount (kcal)');

    await tester.enterText(foodNameField, 'Apple');
    await tester.enterText(calorieField, '-50');
    await tester.tap(addButtonInDialog);
    await tester.pumpAndSettle();

    expect(find.text('Calorie amount must be a valid positive number'), findsOneWidget);

    // Enter valid calorie amount
    await tester.enterText(calorieField, '95');
    await tester.tap(addButtonInDialog);
    await tester.pumpAndSettle();

    // Dialog should be closed and item added
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('95 kcal'), findsNWidgets(2)); // One in card, one in list

    // Remaining calories updated: 2000 - 95 = 1905
    expect(find.text('1905 kcal'), findsOneWidget);

    // Delete food item
    final deleteButton = find.byIcon(Icons.delete);
    expect(deleteButton, findsOneWidget);

    await tester.tap(deleteButton);
    await tester.pumpAndSettle();

    // Item should be removed
    expect(find.text('Apple'), findsNothing);
    expect(find.text('0 kcal'), findsOneWidget);
    expect(find.text('2000 kcal'), findsNWidgets(2));
    expect(find.text('No food items added yet.'), findsOneWidget);
  });
}
