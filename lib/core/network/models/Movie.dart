import 'package:streamrank/core/network/models/Torrent.dart';

class Movie {
  final int id;
  final String title;
  final String titleLong;
  final int year;
  final String description;
  final double rating;
  final String imdbCode;
  final String url;
  final String coverImage;
  final String largeCoverImage;
  final String backgroundImage;
  final List<String> genres;
  final List<Torrent> torrents;
  final String posterPath;
  final double voteAverage;
  final int runtime;
  final String summary;

  Movie({
    required this.id,
    required this.title,
    required this.titleLong,
    required this.year,
    required this.description,
    required this.rating,
    required this.imdbCode,
    required this.url,
    required this.coverImage,
    required this.largeCoverImage,
    required this.backgroundImage,
    required this.genres,
    required this.torrents,
    required this.posterPath,
    required this.voteAverage,
    required this.runtime,
    required this.summary,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final List<Torrent> torrentList = (json['torrents'] as List<dynamic>?)
            ?.map((t) => Torrent.fromJson(t))
            .toList() ??
        [];

    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      titleLong: json['title_long'] ?? json['titleLong'] ?? '',
      year: json['year'] ?? 0,
      description: json['description'] ?? json['description_full'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      imdbCode: json['imdb_code'] ?? json['imdbCode'] ?? '',
      url: json['url'] ?? '',
      coverImage: json['small_cover_image'] ?? json['coverImage'] ?? '',
      largeCoverImage: json['large_cover_image'] ?? json['largeCoverImage'] ?? '',
      backgroundImage: json['background_image'] ?? json['backgroundImage'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      torrents: torrentList,
      posterPath: json['poster_path'] ?? json['posterPath'] ?? '',
      voteAverage: (json['vote_average'] ?? json['voteAverage'] ?? 0.0).toDouble(),
      runtime: json['runtime'] ?? 0,
      summary: json['overview'] ?? json['summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_long': titleLong,
      'description': description,
      'coverImage': coverImage,
      'rating': rating,
      'year': year,
      'imdbCode': imdbCode,
      'url': url,
      'largeCoverImage': largeCoverImage,
      'backgroundImage': backgroundImage,
      'genres': genres,
      'torrents': torrents.map((t) => t.toJson()).toList(),
      'posterPath': posterPath,
      'voteAverage': voteAverage,
      'runtime': runtime,
      'summary': summary,
    };
  }

  @override
  String toString() {
    return 'Movie{id: $id, title: $title, titleLong: $titleLong, year: $year, description: $description, rating: $rating, imdbCode: $imdbCode, url: $url, coverImage: $coverImage, largeCoverImage: $largeCoverImage, backgroundImage: $backgroundImage, genres: ${genres.join(', ')}, torrents: ${torrents.length}, posterPath: $posterPath, voteAverage: $voteAverage, runtime: $runtime, summary: $summary}';
  }
}
