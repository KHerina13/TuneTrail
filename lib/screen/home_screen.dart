import 'package:flutter/material.dart';
import 'package:music_player/Provider/songProvider.dart';
import 'package:music_player/screen/player_screen.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    // Ensure the fetchSong() method is called after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final songProvider = Provider.of<SongProvider>(context, listen: false);
      songProvider.fetchSong();
    });
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(
          "TuneTrail",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade800,
              Colors.purpleAccent.shade100,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                onChanged: (query) {
                  songProvider.searchSongs(query);
                },
                decoration: InputDecoration(
                  hintText: "Search albums...",
                  hintStyle: TextStyle(color: Colors.white70),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
            // Album Grid
            songProvider.loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GridView.builder(
                        itemCount: songProvider.songs.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 columns
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 3 / 4, // Adjust for album shape
                        ),
                        itemBuilder: (context, index) {
                          final song = songProvider.songs[index];
                          return GestureDetector(
                            onTap: () {
                              songProvider
                                  .setCurrentSong(song); // Set the current song
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PlayerScreen(song: song),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.white.withOpacity(0.1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Album Artwork
                                  Container(
                                    height: 130,
                                    width: 130,
                                    margin: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.deepPurple,
                                      image: DecorationImage(
                                        image:
                                            NetworkImage(song.image.toString()),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  // Album Title
                                  Text(
                                    song.name.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 6),
                                  // Artist Name
                                  Text(
                                    song.artist.toString(),
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.deepPurple,
        child: Container(
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Now Playing
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Now Playing",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    songProvider.currentSong?.name ?? "Select a Song",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              // Controls
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (songProvider.currentSong != null) {
                        songProvider.togglePlayPause();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please select a song first")),
                        );
                      }
                    },
                    icon: Icon(
                      songProvider.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                      color: Colors.white,
                    ),
                    iconSize: 45,
                  ),
                  IconButton(
                    onPressed: () {
                      songProvider.stopSong(); // Stop playback
                    },
                    icon: const Icon(
                      Icons.stop_circle,
                      color: Colors.white,
                    ),
                    iconSize: 45,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
