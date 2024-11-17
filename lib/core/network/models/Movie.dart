import 'package:streamrank/core/network/models/Torrent.dart';

class Movie {
  final String title;
  final String titleLong;
  final int year;
  final String description;
  final double rating;
  final String imdbCode;
  final String url;
  final String coverImage;
  final String backgroundImage;
  final List<String> genres;
  final List<Torrent> torrents;

  Movie({
    required this.title,
    required this.titleLong,
    required this.year,
    required this.description,
    required this.rating,
    required this.imdbCode,
    required this.url,
    required this.coverImage,
    required this.backgroundImage,
    required this.genres,
    required this.torrents,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['title'],
      titleLong: json['title_long'],
      year: json['year'],
      description: json['description_full'] ?? '',
      rating: json['rating'].toDouble(),
      imdbCode: json['imdb_code'],
      url: json['url'],
      coverImage: json['small_cover_image'],
      backgroundImage: json['background_image'],
      genres: List<String>.from(json['genres']),
      torrents: (json['torrents'] as List)
          .map((torrent) => Torrent.fromJson(torrent))
          .toList(),
    );
  }
}

