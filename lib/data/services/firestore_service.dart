import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User must be logged in to save movies!");
    }
    return user.uid;
  }

  CollectionReference get _myListRef =>
      _db.collection('users').doc(_userId).collection('my_list');

  Future<void> saveMovie(Movie movie, {bool? inQueue, bool? isWatched, int? rating}) async {
    await _myListRef.doc(movie.id).set({
      'id': movie.id,
      'title': movie.title,
      'posterPath': movie.posterPath,
      'year': movie.releaseDate,
      'overview': movie.overview,
      'genres': movie.genres,

      // ✅ FIXED SYNTAX HERE:
      if (inQueue != null) 'inQueue': inQueue,
      if (isWatched != null) 'isWatched': isWatched,
      if (rating != null) 'rating': rating,

      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot> getMovieStream(String movieId) {
    return _myListRef.doc(movieId).snapshots();
  }

  Stream<QuerySnapshot> getAllMoviesStream() {
    return _myListRef.orderBy('lastUpdated', descending: true).snapshots();
  }

  Stream<QuerySnapshot> getWatchedMoviesStream() {
    return _myListRef
        .where('isWatched', isEqualTo: true)
        .orderBy('lastUpdated', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> getQueueMoviesStream() {
    return _myListRef
        .where('inQueue', isEqualTo: true)
        .snapshots();
  }
}