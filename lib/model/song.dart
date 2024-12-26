import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String? id;
  final String? name;
  final String? artist;
  final String? image;
  final String? url;

  Song({this.id, this.name, this.artist, this.image, this.url});

  // Make sure you fetch all necessary fields from Firestore document
  factory Song.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Song(
      id: doc.id,  // Ensure the id is correctly parsed
      name: data['name'],
      artist: data['artist'],
      image: data['image'],
      url: data['url'],
    );
  }
}
