import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';

void main() {
  runApp(const BookshelfApp());
}

class BookshelfApp extends StatelessWidget {
  const BookshelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookshelf',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ShelfPage(shelf: 'A3', city: 'istanbul', count: 4),
    );
  }
}

class ShelfPage extends StatelessWidget {
  const ShelfPage({
    super.key,
    required this.shelf,
    required this.city,
    required this.count,
  });

  final String shelf;
  final String city;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Column(
        children: [
          // The pickup city as a heading, in capital letters.
          Text(l10n.pickupCity(city).toUpperCase()),
          Text(l10n.booksOnShelf(count, shelf)),
          const Text('Pull to refresh'),
          TextButton(onPressed: () {}, child: Text(l10n.deleteAll)),
        ],
      ),
    );
  }
}
