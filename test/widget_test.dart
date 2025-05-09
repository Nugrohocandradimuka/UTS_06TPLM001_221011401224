import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:candra/main.dart';

void main() {
  testWidgets('Weather app displays city and weather information', (WidgetTester tester) async {
    // Build the WeatherHome widget and trigger a frame.
    await tester.pumpWidget(const CandraWeatherApp());

    // Verify that the app shows the loading indicator initially.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the app to load the weather data (this simulates the weather data fetching delay).
    await tester.pumpAndSettle();

    // Verify that the city name is shown (e.g., it should not be '...' anymore).
    expect(find.text('...'), findsNothing);
    expect(find.textContaining('°C'), findsOneWidget); // Verify that a temperature in Celsius is shown.

    // Verify that the description is shown and contains the expected weather condition.
    expect(find.textContaining('hujan'), findsOneWidget); // Replace 'hujan' with an actual condition from your data.

    // Verify that the weather icon is displayed (the app fetches an icon URL).
    expect(find.byType(Image), findsOneWidget);
  });
}
