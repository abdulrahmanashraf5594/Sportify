import 'package:flutter/material.dart';

import 'home_page.dart';


final pages =[
  HomePage(),
  Center(child: Text("data0000000000000000")),
  Center(child: Text("data100000000000000")),
  Center(child: Text("data200000000000000")),
  Center(child: Text("data200000000000000")),
];
class BottomBar extends StatefulWidget {
  const BottomBar({Key? key}) : super(key: key);

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int indexx =0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indexx,
        type: BottomNavigationBarType.fixed,
        onTap: (index){
          setState(() {
            indexx = index;
          });
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.black12,

        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_filled,
              // color: Colors.white,
              size: 20,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
                // color:Colors.white,
                size: 20,
              ),
              label: ""
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications_on,
              // color:Colors.white,
              size: 20,
            ),
            label: "",
          ),
        ],
      ),
      body: SafeArea(
        child: pages[indexx],
      ),
    );
  }
}