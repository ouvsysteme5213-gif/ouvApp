import 'package:flutter/material.dart';
import 'package:ouv_dooks/vieux/ouvCitaions/ouv_citations.dart';


class OuvDooksHomeNav extends StatefulWidget {
  @override
  State<OuvDooksHomeNav> createState() => OuvDooksHomeNavState();
}

class OuvDooksHomeNavState extends State<OuvDooksHomeNav> {
  int currentPageIndex = 0;

  final _pages = [
    OuvCitations(),
    Text("Livres"),
    Text("Paramètres")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          const NavigationDestination(
            selectedIcon: Icon(Icons.auto_stories_outlined, size: 30,),
            icon: Icon(Icons.auto_stories, size: 30,),
            label: 'Citations',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.menu_book_outlined, size: 30,),
            icon: Icon(Icons.menu_book, size: 30,),
            label: 'Livres',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.settings_outlined, size: 30,),
            icon: Icon(Icons.settings, size: 30,),
            label: 'Paramètres',
          ),
        ],
      ),
    );

  }
}