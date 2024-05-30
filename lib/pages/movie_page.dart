import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie_model.dart';
import '../widgets/login_widget.dart';
import 'review_page.dart';

class MoviePage extends StatefulWidget {
  final Movie movie;

  const MoviePage({Key? key, required this.movie}) : super(key: key);

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  final LoginWidget login = LoginWidget();
  late Future<String> _posterUrlFuture;
  late Future<String> _bannerUrlFuture;

  @override
  void initState() {
    super.initState();
    _posterUrlFuture = _getPosterUrl(widget.movie.moviePosterPath);
    _bannerUrlFuture = _getBannerUrl(widget.movie.movieBannerPath);
  }

  Future<String> _getPosterUrl(String posterPath) async {
    final ref = FirebaseStorage.instance.ref().child('posters/$posterPath');
    return await ref.getDownloadURL();
  }

  Future<String> _getBannerUrl(String bannerPath) async {
    final ref = FirebaseStorage.instance.ref().child('banners/$bannerPath');
    return await ref.getDownloadURL();
  }

  Future<void> _toggleLikeReview(String reviewId, String userId) async {
    final reviewRef =
        FirebaseFirestore.instance.collection('reviews').doc(reviewId);
    final userLikeRef = reviewRef.collection('likes').doc(userId);

    final userLikeSnapshot = await userLikeRef.get();
    if (userLikeSnapshot.exists) {
      await userLikeRef.delete();
      await reviewRef.update({'likes': FieldValue.increment(-1)});
    } else {
      await userLikeRef.set({'userId': userId});
      await reviewRef.update({'likes': FieldValue.increment(1)});
    }
  }

  Future<bool> _hasLikedReview(String reviewId, String userId) async {
    final reviewRef =
        FirebaseFirestore.instance.collection('reviews').doc(reviewId);
    final userLikeRef = reviewRef.collection('likes').doc(userId);

    final userLikeSnapshot = await userLikeRef.get();
    return userLikeSnapshot.exists;
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

  Future<Map<String, dynamic>> _getUserProfile(String userId) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return {
      'username': userDoc['username'],
      'profilePicture': userDoc['profilePicture'] ?? "",
    };
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}a';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}m';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<String>(
              future: _bannerUrlFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 250,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return SizedBox(
                    height: 250,
                    child: Center(child: Text('Error al cargar banner')),
                  );
                } else {
                  return SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: <Color>[Colors.transparent, Colors.black],
                          stops: [0, 1],
                        ).createShader(bounds);
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                }
              },
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 220,
                        child: Text.rich(
                          TextSpan(
                            text: "${widget.movie.name}\n",
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.w300),
                            children: [
                              const TextSpan(
                                text: "\nDIRIGIDO POR \n",
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w200),
                              ),
                              TextSpan(
                                text: widget.movie.director,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: "\n\n${widget.movie.year.toString()}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              TextSpan(
                                text: " - ${widget.movie.genre.toUpperCase()}",
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                      ),
                      FutureBuilder<String>(
                        future: _posterUrlFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: 200,
                              width: 130,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          } else if (snapshot.hasError) {
                            return SizedBox(
                              height: 200,
                              width: 130,
                              child:
                                  Center(child: Text('Error al cargar póster')),
                            );
                          } else {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              height: 200,
                              width: 130,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(snapshot.data!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.movie.description,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 20),
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('reviews')
                        .where('movieId', isEqualTo: widget.movie.name)
                        .orderBy('createdAt', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      var reviews = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          var review = reviews[index];
                          var user = FirebaseAuth.instance.currentUser;

                          return FutureBuilder<Map<String, dynamic>>(
                            future: _getUserProfile(review['userId']),
                            builder: (context, userSnapshot) {
                              if (!userSnapshot.hasData) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              var userProfile = userSnapshot.data!;
                              String username = userProfile['username'];
                              String profilePicture =
                                  userProfile['profilePicture'];
                              return Card(
                                margin: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: profilePicture
                                                    .isNotEmpty
                                                ? NetworkImage(profilePicture)
                                                : AssetImage(
                                                        "assets/default_pfp.jpg")
                                                    as ImageProvider,
                                            radius: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            username,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            _formatTimestamp(
                                                review['createdAt']),
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Text(review['reviewText']),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              FutureBuilder<bool>(
                                                future: _hasLikedReview(
                                                    review.id, user!.uid),
                                                builder:
                                                    (context, likeSnapshot) {
                                                  if (!likeSnapshot.hasData) {
                                                    return Center(
                                                        child:
                                                            CircularProgressIndicator());
                                                  }
                                                  bool hasLiked =
                                                      likeSnapshot.data!;
                                                  return IconButton(
                                                    icon: Icon(
                                                      hasLiked
                                                          ? Icons.thumb_up
                                                          : Icons
                                                              .thumb_up_outlined,
                                                      color: hasLiked
                                                          ? Colors.red
                                                          : null,
                                                    ),
                                                    onPressed: () =>
                                                        _toggleLikeReview(
                                                            review.id,
                                                            user.uid),
                                                  );
                                                },
                                              ),
                                              Text('${review['likes']}'),
                                            ],
                                          ),
                                          if (user.uid == review['userId'])
                                            IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () => _deleteReview(
                                                  context, review.id),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReviewPage(movie: widget.movie),
            ),
          );
        },
        child: Icon(Icons.rate_review),
      ),
    );
  }
}
