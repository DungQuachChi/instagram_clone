import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String uid;
  final String username;
  final String discription;
  final String postId;
  final datePublished;
  final String postUrl;
  final String profImage;
  final likes;

  const Post({
    required this.uid,
    required this.username,
    required this.discription,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'username': username,
    'discription': discription,
    'postId': postId,
    'likes': likes,
    'profImage': profImage,
    'datePublished': datePublished,
    'postUrl': postUrl,
  };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Post(
      username: snapshot['username'],
      uid: snapshot['uid'],
      discription: snapshot['discription'],
      postId: snapshot['postId'],
      profImage: snapshot['profImage'],
      likes: snapshot['likes'],
      datePublished: snapshot['datePublished'],
      postUrl: snapshot['postUrl'],
    );
  }
}
