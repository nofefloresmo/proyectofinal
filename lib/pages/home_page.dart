import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/movie_model.dart';
import 'login_page.dart';
import 'movie_page.dart';
import 'my_reviews_page.dart';
import 'settings_page.dart';
import 'add_movie_page.dart'; // Página para agregar nuevas películas
import 'edit_movie_page.dart'; // Página para editar películas
import 'delete_movie_page.dart'; // Página para eliminar películas
import 'logs_page.dart'; // Página para visualizar logs de transacciones

class HomePage extends StatelessWidget {
  final User user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  Future<String> getUserRole() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc['role'];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.data == 'admin') {
          return AdminHomePage(user: user);
        } else {
          return RegularHomePage(user: user);
        }
      },
    );
  }
}

class AdminHomePage extends StatefulWidget {
  final User user;
  const AdminHomePage({super.key, required this.user});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar cierre de sesión'),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                });
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
    return Scaffold(
      drawer: Drawer(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/admin_banner.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                child: const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/admin_pfp.jpg"),
                ),
              ),
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.home,
                        color: Colors.white,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.white, blurRadius: 18),
                          Shadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Inicio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.white, blurRadius: 18),
                          Shadow(
                              color: Colors.white.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.add,
                        color: Colors.blueAccent,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.blueAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Insertar Películas',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.blueAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddMoviePage()),
                );
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.edit,
                        color: Colors.orangeAccent,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.orangeAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.orangeAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Editar Películas',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.orangeAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.orangeAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditMoviePage()),
                );
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.delete,
                        color: Colors.redAccent,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.redAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Eliminar Películas',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.redAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeleteMoviePage()),
                );
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.history,
                        color: Colors.orangeAccent,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.orangeAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.orangeAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Logs',
                      style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.orangeAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.orangeAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogsPage()),
                );
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.logout,
                        color: Colors.redAccent,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.redAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.redAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Admin Home'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('movies').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No hay datos disponibles.'));
          }

          var movies = snapshot.data!.docs;

          int totalMovies = movies.length;
          Map<String, int> genreCounts = {};

          for (var doc in movies) {
            List<String> movieGenres = (doc['genre'] as String)
                .split(', ')
                .map((genre) => genre.trim())
                .toList();
            for (String genre in movieGenres) {
              if (genreCounts.containsKey(genre)) {
                genreCounts[genre] = genreCounts[genre]! + 1;
              } else {
                genreCounts[genre] = 1;
              }
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estadísticas',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Total de Películas: $totalMovies',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Películas por Género:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: genreCounts.keys.length,
                    itemBuilder: (context, index) {
                      String genre = genreCounts.keys.elementAt(index);
                      int count = genreCounts[genre]!;
                      return ListTile(
                        title: Text(genre),
                        trailing: Text(count.toString()),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class RegularHomePage extends StatefulWidget {
  final User user;
  const RegularHomePage({super.key, required this.user});

  @override
  State<RegularHomePage> createState() => _RegularHomePageState();
}

class _RegularHomePageState extends State<RegularHomePage> {
  List<Movie> _movies = [];
  String? profilePictureUrl;
  String? bannerPictureUrl;
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    Movie.loadMovies().then((movies) {
      setState(() {
        _movies = movies;
      });
    });
  }

  Future<void> _loadUserProfile() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();
    setState(() {
      profilePictureUrl = doc['profilePicture'];
      bannerPictureUrl = doc['bannerPicture'];
      username = doc['username'];
    });
  }

  Future<String> _getPosterUrl(String posterPath) async {
    final ref = FirebaseStorage.instance.ref().child('posters/$posterPath');
    return await ref.getDownloadURL();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar cierre de sesión'),
          content: Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                });
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
    return Scaffold(
      drawer: Drawer(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                image: bannerPictureUrl != null && bannerPictureUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(bannerPictureUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Container(
                height: double.infinity,
                width: double.infinity,
                alignment: Alignment.center,
                child: CircleAvatar(
                  radius: 60,
                  child: ClipOval(
                    child: profilePictureUrl != null &&
                            profilePictureUrl!.isNotEmpty
                        ? Image.network(
                            profilePictureUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "assets/default_pfp.jpg",
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                username,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Text(
                widget.user.email!,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.home,
                        color: Colors.blueAccent,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.blueAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Inicio',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.blueAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.blueAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.rate_review,
                        color: Colors.greenAccent,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.greenAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.greenAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Mis reseñas',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.greenAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.greenAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MyReviewsPage()));
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.settings,
                        color: Colors.amber,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.amber, blurRadius: 18),
                          Shadow(
                              color: Colors.amber.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Configuración',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.amber, blurRadius: 18),
                          Shadow(
                              color: Colors.amber.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(user: widget.user)));
              },
            ),
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Icon(Icons.logout,
                        color: Colors.redAccent,
                        size: 30,
                        shadows: [
                          Shadow(color: Colors.redAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ]),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      'Cerrar sesión',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(color: Colors.redAccent, blurRadius: 18),
                          Shadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Películas'),
      ),
      body: _movies.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                moviesByGenreLV('Action', getMoviesByGenre('Action')),
                moviesByGenreLV('Thriller', getMoviesByGenre('Thriller')),
                moviesByGenreLV('Comedy', getMoviesByGenre('Comedy')),
                moviesByGenreLV('Crime', getMoviesByGenre('Crime')),
                moviesByGenreLV('Drama', getMoviesByGenre('Drama')),
                moviesByGenreLV('Horror', getMoviesByGenre('Horror')),
                moviesByGenreLV('Sci-Fi', getMoviesByGenre('Sci-Fi')),
                moviesByGenreLV('Romance', getMoviesByGenre('Romance')),
                moviesByGenreLV('Adventure', getMoviesByGenre('Adventure')),
                moviesByGenreLV('Fantasy', getMoviesByGenre('Fantasy')),
                moviesByGenreLV('Music', getMoviesByGenre('Music')),
                moviesByGenreLV('Family', getMoviesByGenre('Family')),
              ],
            ),
    );
  }

  List<Movie> getMoviesByGenre(String genre) {
    return _movies.where((movie) => movie.genre.contains(genre)).toList();
  }

  Widget moviesByGenreLV(String genre, List<Movie> movies) {
    final Map<String, Color> genresByColor = {
      "Action": Colors.redAccent,
      "Comedy": Colors.greenAccent,
      "Drama": Colors.blueAccent,
      "Horror": Colors.purpleAccent,
      "Sci-Fi": Colors.orangeAccent,
      "Adventure": Colors.yellowAccent,
      "Fantasy": Colors.pinkAccent,
      "Family": Colors.tealAccent,
      "Thriller": Colors.amberAccent,
      "Crime": Colors.deepOrangeAccent,
      "Music": Colors.limeAccent,
      "Romance": Colors.indigoAccent,
    };

    final bool isPopular = genre == "Popular";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            genre,
            style: TextStyle(
              fontFamily: "NeonTubes",
              fontSize: isPopular ? 40 : 30,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.7),
              shadows: [
                Shadow(
                  color: isPopular ? Colors.pinkAccent : genresByColor[genre]!,
                  blurRadius: 18,
                ),
                Shadow(
                  color: isPopular
                      ? Colors.pinkAccent
                      : genresByColor[genre]!.withOpacity(0.5),
                  blurRadius: 28,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        SizedBox(
          height: isPopular ? 330 : 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: isPopular ? 180 : 130,
                    alignment: Alignment.center,
                    child: Text(movies[index].name,
                        style: TextStyle(
                          shadows: [
                            Shadow(
                              color: isPopular
                                  ? Colors.pinkAccent
                                  : genresByColor[genre]!,
                              blurRadius: 18,
                            ),
                            Shadow(
                              color: isPopular
                                  ? Colors.pinkAccent
                                  : genresByColor[genre]!.withOpacity(0.5),
                              blurRadius: 28,
                            ),
                          ],
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        )),
                  ),
                  const SizedBox(height: 5),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  MoviePage(movie: movies[index])));
                    },
                    child: FutureBuilder(
                      future: _getPosterUrl(movies[index].moviePosterPath),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Icon(Icons.error);
                        } else {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            height: isPopular ? 300 : 200,
                            width: isPopular ? 190 : 130,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                image: NetworkImage(snapshot.data!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
