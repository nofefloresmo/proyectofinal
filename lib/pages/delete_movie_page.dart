import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/log_model.dart';

class DeleteMoviePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eliminar Película'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('movies').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var movies = snapshot.data!.docs;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              var movie = movies[index];
              return ListTile(
                title: Text(movie['name']),
                subtitle: Text(movie['director']),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteDialog(context, movie);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, DocumentSnapshot movie) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar esta película?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteMovie(movie);
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMovie(DocumentSnapshot movie) async {
    String posterPath = movie['movie_poster_path'];
    String bannerPath = movie['movie_banner_path'];

    // Registro del log en la base de datos local
    await Log.insertLog(Log(
      action: 'Eliminar',
      movieName: movie['name'],
      timestamp: DateTime.now(),
    ));

    // Eliminar documento de Firestore
    await FirebaseFirestore.instance
        .collection('movies')
        .doc(movie.id)
        .delete();

    // Eliminar póster y banner de Firebase Storage
    await FirebaseStorage.instance.ref('posters/$posterPath').delete();
    await FirebaseStorage.instance.ref('banners/$bannerPath').delete();
  }
}
