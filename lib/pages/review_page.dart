import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/movie_model.dart';
import '../models/review_model.dart';
import '../widgets/login_widget.dart';

class ReviewPage extends StatefulWidget {
  final Movie movie;

  const ReviewPage({Key? key, required this.movie}) : super(key: key);

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final LoginWidget login = LoginWidget();
  double _currentRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  Future<void> _saveReview() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Debes estar registrado para hacer una reseña.')),
      );
      return;
    }

    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor llena todos los campos.')),
      );
      return;
    }

    try {
      final review = Review(
        movieId: widget.movie.name,
        userId: user.uid,
        rating: _currentRating.toInt(),
        reviewText: _reviewController.text.trim(),
        createdAt: Timestamp.now(),
      );

      await FirebaseFirestore.instance
          .collection('reviews')
          .add(review.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reseña añadida exitosamente.')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir la reseña: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 210,
              child: Text(
                widget.movie.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
            login.getLogo(20),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Cómo calificas?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RatingBar.builder(
              initialRating: 0,
              minRating: 0,
              direction: Axis.horizontal,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.white.withOpacity(0.8),
                shadows: [
                  Shadow(
                    color: login.getNeonColor(),
                    blurRadius: 48,
                  ),
                  Shadow(
                    color: login.getNeonColor().withOpacity(0.5),
                    blurRadius: 58,
                  ),
                ],
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _currentRating = rating;
                });
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Tu Review',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                fillColor: Colors.white.withOpacity(0.05),
                filled: true,
                hintText: "Escribe aquí tus pensamientos sobre la peli...",
                hintStyle: const TextStyle(
                  color: Colors.white10,
                ),
                labelText: " Review",
                alignLabelWithHint: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF252525),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFF03A9F4),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFB00020),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xFFB00020),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 200,
                height: 55,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      login.getStartingColor(),
                      login.getNeonColor(),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: _saveReview,
                    child: const Center(
                      child: Text(
                        'Enviar Review',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Puedes ver de nuevo en',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
