import 'package:flutter/material.dart';
import 'dart:math';
import 'package:share_plus/share_plus.dart';

void main() => runApp(QuoteApp());

class QuoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quote of the Day',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 24),
        ),
      ),
      home: QuoteHomePage(),
    );
  }
}

class QuoteHomePage extends StatefulWidget {
  @override
  _QuoteHomePageState createState() => _QuoteHomePageState();
}

class _QuoteHomePageState extends State<QuoteHomePage> {
  final List<String> quotes = [
    "Believe in yourself.",
    "You are stronger than you think.",
    "Every day is a second chance.",
    "Be the change you wish to see.",
    "Dream it. Wish it. Do it.",
    "Success is not final, failure is not fatal.",
    "Push yourself, because no one else is going to do it for you.",
  ];

  String currentQuote = '';
  List<String> favoriteQuotes = [];

  @override
  void initState() {
    super.initState();
    _loadNewQuote();
  }

  void _loadNewQuote() {
    setState(() {
      currentQuote = quotes[Random().nextInt(quotes.length)];
    });
  }

  void _toggleFavorite() {
    if (!favoriteQuotes.contains(currentQuote)) {
      setState(() {
        favoriteQuotes.add(currentQuote);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Added to favorites"),
        duration: Duration(seconds: 1),
      ));
    }
  }

  void _shareQuote() {
    Share.share(currentQuote);
  }

  void _showFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FavoriteQuotesPage(favoriteQuotes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quote of the Day"),
        actions: [
          IconButton(
            icon: Icon(Icons.favorite),
            onPressed: _showFavorites,
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              currentQuote,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _loadNewQuote,
              icon: Icon(Icons.refresh),
              label: Text("New Quote"),
            ),
            ElevatedButton.icon(
              onPressed: _toggleFavorite,
              icon: Icon(Icons.favorite_border),
              label: Text("Add to Favorites"),
            ),
            ElevatedButton.icon(
              onPressed: _shareQuote,
              icon: Icon(Icons.share),
              label: Text("Share"),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteQuotesPage extends StatelessWidget {
  final List<String> favorites;
  FavoriteQuotesPage(this.favorites);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Favorite Quotes")),
      body: ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (_, index) => ListTile(
          leading: Icon(Icons.format_quote),
          title: Text(favorites[index]),
        ),
      ),
    );
  }
}
