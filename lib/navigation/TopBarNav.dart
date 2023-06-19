import 'package:flutter/material.dart';
import 'package:cloudjams/screens/LibraryPage.dart';
import 'package:cloudjams/screens/PlayListPage.dart';
import 'package:cloudjams/screens/PlayingPage.dart';

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
                //TODO 换图标
                child: Text("PlayList"),
              ),
              Tab(
                //TODO 换图标
                child: Text("Playing"),
              ),
              Tab(
                //TODO 换图标
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
