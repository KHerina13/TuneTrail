import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/model/song.dart';

class SongProvider with ChangeNotifier {
  List<Song> _songs = [];
  List<Song> _filteredSongs = [];
  bool _isLoading = false;
  Song? _currentSong;
  bool _isPlaying = false;

  List<Song> get songs => _filteredSongs.isEmpty ? _songs : _filteredSongs;

  bool get loading => _isLoading;

  Song? get currentSong => _currentSong;

  bool get isPlaying => _isPlaying;
  final AudioPlayer audioPlayer = AudioPlayer();

  Future<void> fetchSong() async {
    _isLoading = true;  // Set loading state to true
    notifyListeners();

    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection("songs").get();
      if (snapshot.docs.isEmpty) {
        print("No songs found.");
      } else {
        _songs = snapshot.docs.map((doc) => Song.fromFirestore(doc)).toList();
        _filteredSongs = _songs; // Initialize with all songs
        print("Fetched ${_songs.length} songs.");
      }
    } catch (e) {
      print("Error fetching songs: $e");
    } finally {
      _isLoading = false;  // Set loading state to false after fetching data
      notifyListeners();
    }
  }

  void searchSongs(String query) {
    if (query.isEmpty) {
      _filteredSongs = _songs; // Reset to all songs if search is cleared
    } else {
      _filteredSongs = _songs
          .where((song) =>
      song.name!.toLowerCase().contains(query.toLowerCase()) ||
          song.artist!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }
  void setCurrentSong(Song song) async {
    _currentSong = song;
    _isPlaying = true;
    notifyListeners();

    try {
      await audioPlayer
          .setUrl(song.url.toString()); // Load the song into the player
      await audioPlayer.play();
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  void togglePlayPause() async {
    if (_isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void stopSong() async {
    await audioPlayer.stop();
    _isPlaying = false;
    _currentSong = null;
    notifyListeners();
  }
}
