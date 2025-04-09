import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR APP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
       textTheme: TextTheme(
  titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
  titleSmall: TextStyle(color: const Color.fromARGB(255, 31, 39, 196), fontSize: 12),
 ),
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR APP'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // TODO: Implement drawer functionality
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Nombre total de',
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'formations',
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '12',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Nombre de',
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'participants actifs',
                            style: Theme.of(context).textTheme.titleSmall,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            '24',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Formations :',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Implement "voir tout" functionality
                    },
                    child: Text('voir tout', style: TextStyle(color: Colors.blue)),
                  ),
                ],
              ),
            ),
            _buildFormationCard(
              context,
              'Formations java',
              '18 mars, 14h:30m',
              '25 participants',
            ),
            _buildFormationCard(
              context,
              'Formations python',
              '20 mars, 14h:30m',
              '25 participants',
            ),
            _buildFormationCard(
              context,
              'Formations HTML',
              '28 mars, 14h:30m',
              '25 participants',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Formations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Participants',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget _buildFormationCard(
      BuildContext context, String title, String date, String participants) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              date,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              participants,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}