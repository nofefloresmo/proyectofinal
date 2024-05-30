import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Movie {
  final String name;
  final String director;
  final int year;
  final String genre;
  final String description;
  final String moviePosterPath;
  final String movieBannerPath;

  Movie({
    required this.name,
    required this.director,
    required this.year,
    required this.genre,
    required this.description,
    required this.moviePosterPath,
    required this.movieBannerPath,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'director': director,
      'year': year,
      'genre': genre,
      'description': description,
      'movie_poster_path': moviePosterPath,
      'movie_banner_path': movieBannerPath,
    };
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      name: map['name'],
      director: map['director'],
      year: map['year'],
      genre: map['genre'],
      description: map['description'],
      moviePosterPath: map['movie_poster_path'],
      movieBannerPath: map['movie_banner_path'],
    );
  }

  factory Movie.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Movie.fromMap(data);
  }

  static Future<List<Movie>> loadMovies() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('movies').get();
    return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
  }

  Future<String> getMoviePoster() async {
    return await FirebaseStorage.instance
        .ref('posters/$moviePosterPath')
        .getDownloadURL();
  }

  Future<String> getMovieBanner() async {
    return await FirebaseStorage.instance
        .ref('banners/$movieBannerPath')
        .getDownloadURL();
  }

  static Future<List<Movie>> getMoviesByGenre(String genre) async {
    List<Movie> movies = await loadMovies();
    return movies.where((movie) => movie.genre.contains(genre)).toList();
  }
}
