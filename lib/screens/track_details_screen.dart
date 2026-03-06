import 'package:flutter/material.dart';

class TrackDetailsScreen extends StatelessWidget {
  const TrackDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Track Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              "https://via.placeholder.com/400",
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),

           SizedBox(height: 20),

            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                   Text(
                    "Track Title",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                   SizedBox(height: 15),

                  Row(
                    children:  [
                      CircleAvatar(
                        radius: 22,
                        child: Icon(Icons.person),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Artist Name",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                   SizedBox(height: 15),

                  Row(
                    children:  [
                      Icon(Icons.album),
                      SizedBox(width: 10),
                      Text(
                        "Album Name",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                   SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    children:  [

                      Chip(
                        avatar: Icon(Icons.timer, size: 18),
                        label: Text("Duration: 3:40"),
                      ),

                      Chip(
                        avatar: Icon(Icons.trending_up, size: 18),
                        label: Text("Rank: 1"),
                      ),

                      Chip(
                        avatar: Icon(Icons.tag, size: 18),
                        label: Text("Track ID: 123"),
                      ),

                      Chip(
                        avatar: Icon(Icons.explicit, size: 18),
                        label: Text("Explicit"),
                      ),
                    ],
                  ),

                   SizedBox(height: 30),

                   Text(
                    "Lyrics",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                   SizedBox(height: 10),

                  Container(
                    padding:  EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:  Text(
                      "Lyrics will appear here...",
                      style: TextStyle(height: 1.6),
                    ),
                  ),

                   SizedBox(height: 40),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}