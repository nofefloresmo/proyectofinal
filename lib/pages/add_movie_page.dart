import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../models/log_model.dart';

class AddMoviePage extends StatefulWidget {
  @override
  _AddMoviePageState createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _directorController = TextEditingController();
  final _yearController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _posterImage;
  File? _bannerImage;
  bool _isUploading = false;
  List<String> _selectedGenres = [];
  List<String> _genres = [];

  @override
  void initState() {
    super.initState();
    _fetchGenres();
  }

  Future<void> _fetchGenres() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('movies').get();
    Set<String> genres = {};

    for (var doc in querySnapshot.docs) {
      List<String> movieGenres = (doc['genre'] as String)
          .split(', ')
          .map((genre) => genre.trim())
          .toList();
      genres.addAll(movieGenres);
    }

    setState(() {
      _genres = genres.toList();
    });
  }

  Future<void> _pickImage(ImageSource source, bool isPoster) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isPoster) {
          _posterImage = File(pickedFile.path);
        } else {
          _bannerImage = File(pickedFile.path);
        }
      });
    }
  }

  String _getImageExtension(File image) {
    String path = image.path;
    return path.substring(path.lastIndexOf('.'));
  }

  Future<String> _uploadImage(File image, String path) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(path);
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask;
    return await storageReference.getDownloadURL();
  }

  Future<bool> _isMovieNameUnique(String name) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('movies')
        .where('name', isEqualTo: name)
        .get();
    return querySnapshot.docs.isEmpty;
  }

  Future<void> _addMovie() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_posterImage == null || _bannerImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona un póster y un banner')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    bool isUnique = await _isMovieNameUnique(_nameController.text.trim());

    if (!isUnique) {
      setState(() {
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ya existe una película con ese nombre')),
      );
      return;
    }

    try {
      String posterExtension = _getImageExtension(_posterImage!);
      String bannerExtension = _getImageExtension(_bannerImage!);
      String posterPath = '${_nameController.text.trim()}$posterExtension';
      String bannerPath = '${_nameController.text.trim()}$bannerExtension';
      // ignore: unused_local_variable
      String posterUrl =
          await _uploadImage(_posterImage!, 'posters/$posterPath');
      // ignore: unused_local_variable
      String bannerUrl =
          await _uploadImage(_bannerImage!, 'banners/$bannerPath');

      String genres = _selectedGenres.join(', ');

      await FirebaseFirestore.instance.collection('movies').add({
        'name': _nameController.text.trim(),
        'director': _directorController.text.trim(),
        'year': int.parse(_yearController.text.trim()),
        'genre': genres,
        'description': _descriptionController.text.trim(),
        'movie_poster_path': posterPath,
        'movie_banner_path': bannerPath,
      });

      // Registro del log en la base de datos local
      await Log.insertLog(Log(
        action: 'Insertar',
        movieName: _nameController.text.trim(),
        timestamp: DateTime.now(),
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Película añadida exitosamente')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir película: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Película'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre de la Película'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce el nombre de la película';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _directorController,
                decoration: InputDecoration(labelText: 'Director'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce el director de la película';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: InputDecoration(labelText: 'Año'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce el año de la película';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor introduce un año válido';
                  }
                  return null;
                },
              ),
              MultiSelectDialogField(
                items: _genres
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
                onConfirm: (results) {
                  _selectedGenres = results.cast<String>();
                },
                validator: (values) {
                  if (values == null || values.isEmpty) {
                    return "Por favor selecciona al menos un género";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor introduce una descripción para la película';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _posterImage != null
                  ? Image.file(_posterImage!, height: 150)
                  : Text('No se ha seleccionado póster'),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery, true),
                child: Text('Seleccionar Póster'),
              ),
              const SizedBox(height: 20),
              _bannerImage != null
                  ? Image.file(_bannerImage!, height: 150)
                  : Text('No se ha seleccionado banner'),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery, false),
                child: Text('Seleccionar Banner'),
              ),
              const SizedBox(height: 20),
              _isUploading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _addMovie,
                      child: Text('Agregar Película'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
