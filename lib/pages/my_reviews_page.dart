import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyReviewsPage extends StatefulWidget {
  const MyReviewsPage({super.key});

  @override
  State<MyReviewsPage> createState() => _MyReviewsPageState();
}

class _MyReviewsPageState extends State<MyReviewsPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<DocumentSnapshot?> _getMovieById(String movieName) async {
    var query = await FirebaseFirestore.instance
        .collection('movies')
        .where('name', isEqualTo: movieName)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first;
    }
    return null;
  }

  Future<void> _deleteReview(BuildContext context, String reviewId) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar esta reseña?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('reviews')
                    .doc(reviewId)
                    .delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reseña eliminada exitosamente.')),
                );
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Mis Reseñas')),
        body: Center(child: Text('No has iniciado sesión')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Mis Reseñas')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('userId', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No has hecho ninguna reseña'));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Ocurrió un error al cargar las reseñas'));
          }

          var reviews = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              var review = reviews[index];
              return FutureBuilder<DocumentSnapshot?>(
                future: _getMovieById(review['movieId']),
                builder: (context, movieSnapshot) {
                  if (movieSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return ListTile(title: Text('Cargando...'));
                  }
                  if (movieSnapshot.hasError) {
                    return ListTile(title: Text('Error al cargar película'));
                  }
                  if (!movieSnapshot.hasData || !movieSnapshot.data!.exists) {
                    return ListTile(title: Text('Película no encontrada'));
                  }

                  var movie = movieSnapshot.data!;
                  var movieData = movie.data() as Map<String, dynamic>?;

                  if (movieData == null) {
                    return ListTile(
                        title: Text('Datos de película no encontrados'));
                  }

                  return ListTile(
                    title: Text(movieData['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Director: ${movieData['director']}'),
                        Text('Año: ${movieData['year']}'),
                        Text('Géneros: ${movieData['genre']}'),
                        Text('Reseña: ${review['reviewText']}'),
                        Row(
                          children: [
                            Text('Calificación: ${review['rating']}'),
                            SizedBox(width: 10),
                            Text('Likes: ${review['likes']}'),
                          ],
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteReview(context, review.id);
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
