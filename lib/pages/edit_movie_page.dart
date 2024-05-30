import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../models/log_model.dart';

class EditMoviePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Película'),
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
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showEditDialog(context, movie);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, DocumentSnapshot movie) {
    final _directorController = TextEditingController(text: movie['director']);
    final _yearController =
        TextEditingController(text: movie['year'].toString());
    final _descriptionController =
        TextEditingController(text: movie['description']);
    final _currentGenres = (movie['genre'] as String)
        .split(', ')
        .map((genre) => genre.trim())
        .toList();
    List<String> _selectedGenres = List<String>.from(_currentGenres);

    // Fetch all available genres
    FirebaseFirestore.instance.collection('movies').get().then((querySnapshot) {
      Set<String> allGenres = {};

      for (var doc in querySnapshot.docs) {
        List<String> movieGenres = (doc['genre'] as String)
            .split(', ')
            .map((genre) => genre.trim())
            .toList();
        allGenres.addAll(movieGenres);
      }

      _showDialog(
          context,
          movie,
          _directorController,
          _yearController,
          _descriptionController,
          _currentGenres,
          allGenres.toList(),
          _selectedGenres);
    });
  }

  void _showDialog(
      BuildContext context,
      DocumentSnapshot movie,
      TextEditingController directorController,
      TextEditingController yearController,
      TextEditingController descriptionController,
      List<String> currentGenres,
      List<String> allGenres,
      List<String> selectedGenres) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Película'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: directorController,
                  decoration: InputDecoration(labelText: 'Director'),
                ),
                TextFormField(
                  controller: yearController,
                  decoration: InputDecoration(labelText: 'Año'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Descripción'),
                ),
                const SizedBox(height: 10),
                Text('Géneros actuales'),
                Wrap(
                  spacing: 8.0,
                  children: currentGenres.map((genre) {
                    return Chip(
                      label: Text(genre),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Text('Seleccionar nuevos géneros'),
                MultiSelectDialogField(
                  items: allGenres
                      .map((genre) => MultiSelectItem(genre, genre))
                      .toList(),
                  title: Text("Géneros"),
                  selectedColor: Colors.blue,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  buttonIcon: Icon(
                    Icons.movie,
                    color: Colors.blue,
                  ),
                  buttonText: Text(
                    "Seleccionar Géneros",
                    style: TextStyle(
                      color: Colors.blue[800],
                      fontSize: 16,
                    ),
                  ),
                  initialValue: selectedGenres,
                  onConfirm: (results) {
                    selectedGenres = results.cast<String>();
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                String genres = selectedGenres.join(', ');

                await FirebaseFirestore.instance
                    .collection('movies')
                    .doc(movie.id)
                    .update({
                  'director': directorController.text.trim(),
                  'year': int.parse(yearController.text.trim()),
                  'description': descriptionController.text.trim(),
                  'genre': genres,
                });

                // Registro del log en la base de datos local
                await Log.insertLog(Log(
                  action: 'Modificar',
                  movieName: movie['name'],
                  timestamp: DateTime.now(),
                ));

                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
