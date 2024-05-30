import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String movieId;
  final String userId;
  final int rating;
  final String reviewText;
  final int likes;
  final Timestamp createdAt; // Usa Timestamp de Firestore

  Review({
    required this.movieId,
    required this.userId,
    required this.rating,
    required this.reviewText,
    this.likes = 0,
    required this.createdAt, // Añadir el campo creado
  });

  Map<String, dynamic> toMap() {
    return {
      'movieId': movieId,
      'userId': userId,
      'rating': rating,
      'reviewText': reviewText,
      'likes': likes,
      'createdAt': createdAt, // Añadir el campo creado
    };
  }

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      movieId: map['movieId'],
      userId: map['userId'],
      rating: map['rating'],
      reviewText: map['reviewText'],
      likes: map['likes'] ?? 0,
      createdAt: map['createdAt'], // Añadir el campo creado
    );
  }

  String toJson() => json.encode(toMap());

  factory Review.fromJson(String source) => Review.fromMap(json.decode(source));
}
