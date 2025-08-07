import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(110),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFCCF2FF), Color(0xFF99CCFF)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Inochat',
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.search, color: Colors.blue[900]),
                            SizedBox(width: 16),
                            Icon(Icons.more_vert, color: Colors.blue[900]),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TabBar(
                    indicatorColor: Colors.blue[900],
                    labelColor: Colors.blue[900],
                    unselectedLabelColor: Colors.grey,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(text: 'Contacts'),
                      Tab(text: 'Chat'),
                      Tab(text: 'Status'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFCCF2FF), Color(0xFF99CCFF)],
            ),
          ),
          child: TabBarView(
            children: [
              Center(
                child: Text(
                  'Contacts',
                  style: TextStyle(fontSize: 18, color: Colors.blue[900]),
                ),
              ),
              ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/men/1.jpg',
                      ),
                    ),
                    title: Text(
                      'Keith Mills',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Hey, would you be interested in ...'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('24m ago', style: TextStyle(fontSize: 12)),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.green,
                          child: Text(
                            '2',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/women/2.jpg',
                      ),
                    ),
                    title: Text(
                      'Hannah Chavez',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('How about PayPal? Let me kn ...'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('40m ago', style: TextStyle(fontSize: 12)),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.green,
                          child: Text(
                            '1',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/women/3.jpg',
                      ),
                    ),
                    title: Text(
                      'Ann Bates',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('My final price would be 5k. Not m ...'),
                    trailing: Text('1h ago', style: TextStyle(fontSize: 12)),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/women/4.jpg',
                      ),
                    ),
                    title: Text(
                      'Martha Gram',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Let’s do this. Meet me at Starbucks'),
                    trailing: Text('2d ago', style: TextStyle(fontSize: 12)),
                  ),
                  // Add more ListTiles as needed
                ],
              ),
              Center(
                child: Text(
                  'Status',
                  style: TextStyle(fontSize: 18, color: Colors.blue[900]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
