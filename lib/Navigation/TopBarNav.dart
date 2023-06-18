import 'package:flutter/material.dart';
import 'package:cloudjams/contentPages/LibraryPage.dart';
import 'package:cloudjams/contentPages/PlayListPage.dart';
import 'package:cloudjams/contentPages/PlayingPage.dart';

class TopBarNavigation extends StatelessWidget {
  const TopBarNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const TabBar(
            tabs: <Widget>[
              Tab(
                child: Text("PlayList"),
              ),
              Tab(
                child: Text("Playing"),
              ),
              Tab(
                child: Text("Library"),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            PlayListPage(),
            PlayingPage(),
            LibraryPage(),
          ],
        ),
      ),
    );
  }
}
