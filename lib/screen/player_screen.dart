import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/model/song.dart';
import 'package:provider/provider.dart';

import '../Provider/songProvider.dart';

class PlayerScreen extends StatefulWidget {
  final Song song;

  PlayerScreen({required this.song});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late AudioPlayer audioPlayer;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioPlayer.setUrl(widget.song.url.toString());
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final songProvider = Provider.of<SongProvider>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "TuneTrail",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple,
              Colors.purpleAccent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Album Art
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 100,
                backgroundColor: Colors.white,
                child: widget.song.image != null
                    ? ClipOval(
                  child: Image.network(
                    widget.song.image!,
                    fit: BoxFit.cover,
                    width: 200,
                    height: 200,
                  ),
                )
                    : Icon(
                  Icons.music_note_outlined,
                  size: 80,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            SizedBox(height: 30),

            // Song Title and Artist
            Text(
              widget.song.name ?? "Song Name",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              widget.song.artist ?? "Artist Name",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),

            // Slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: StreamBuilder<Duration>(
                  stream: songProvider.audioPlayer.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = songProvider.audioPlayer.duration ?? Duration.zero;
                    return Column(
                      children: [
                        Slider(
                          value: position.inSeconds.toDouble(),
                          max: duration.inSeconds.toDouble(),
                          activeColor: Colors.purpleAccent,
                          inactiveColor: Colors.white38,
                          onChanged: (val) {
                            songProvider.audioPlayer.seek(Duration(seconds: val.toInt()));
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatTime(position),
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              formatTime(duration),
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),
            ),

            // Controls
            SizedBox(height: 20),
            StreamBuilder(
              stream: songProvider.audioPlayer.playerStateStream,
              builder: (context, snapshot) {
                final playerState = snapshot.data;
                final isPlaying = playerState?.playing ?? false;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.shuffle, color: Colors.white70),
                      onPressed: () {

                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(20),
                        backgroundColor: Colors.purpleAccent,
                        elevation: 10,
                      ),
                      onPressed: () {
                        if (songProvider.currentSong != null) {
                          songProvider.togglePlayPause();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select a song first")),
                          );
                        }
                      },
                      child: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.repeat, color: Colors.white70),
                      onPressed: () {
                        // Repeat functionality here
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
