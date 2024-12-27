import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/network/models/Torrent.dart';

class FavoriteMovie extends Movie {
  final int idFavoriteMovie;

  FavoriteMovie({
    required this.idFavoriteMovie,
    required int id,
    required String title,
    required String titleLong,
    required String description,
    required String coverImage,
    required double rating,
    required int year,
    required String imdbCode,
    required String url,
    required String largeCoverImage,
    required String backgroundImage,
    required List<String> genres,
    required List<Torrent> torrents,
    required String posterPath,
    required double voteAverage,
    required int runtime,
    required String summary,
  }) : super(
          id: id,
          title: title,
          titleLong: titleLong,
          description: description,
          coverImage: coverImage,
          rating: rating,
          year: year,
          imdbCode: imdbCode,
          url: url,
          largeCoverImage: largeCoverImage,
          backgroundImage: backgroundImage,
          genres: genres,
          torrents: torrents,
          posterPath: posterPath,
          voteAverage: voteAverage,
          runtime: runtime,
          summary: summary,
        );

  factory FavoriteMovie.fromSpringJson(Map<String, dynamic> json) {
    final List<Torrent> torrentList = (json['availableDownloadLinks'] as List<dynamic>?)
            ?.map((link) => Torrent(
                  url: link,
                  quality: "720p",
                  size: "0",
                ))
            .toList() ??
        [];

    return FavoriteMovie(
      idFavoriteMovie: json['idFavoriteMovie'] ?? 0,
      id: json['idMovie'] ?? 0,
      title: json['movieTitle'] ?? '',
      titleLong: json['movieTitle'] ?? '',
      year: int.tryParse(json['movieReleaseDate'] ?? '0') ?? 0,
      description: '',  // Not provided in Spring response
      rating: double.tryParse(json['movieRating'] ?? '0.0') ?? 0.0,
      imdbCode: '',  // Not provided in Spring response
      url: '',  // Not provided in Spring response
      coverImage: json['imageCover'] ?? '',
      largeCoverImage: json['imageCover'] ?? '',  // Using same as cover image
      backgroundImage: json['imageCover'] ?? '',  // Using same as cover image
      genres: List<String>.from(json['movieGenre'] ?? []),
      torrents: torrentList,
      posterPath: json['imageCover'] ?? '',  // Using same as cover image
      voteAverage: double.tryParse(json['movieRating'] ?? '0.0') ?? 0.0,
      runtime: 0,  // Not provided in Spring response
      summary: '',  // Not provided in Spring response
    );
  }

  // Keep the old fromJson for backward compatibility with User model
  factory FavoriteMovie.fromJson(Map<String, dynamic> json) {
    return FavoriteMovie.fromSpringJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'idFavoriteMovie': idFavoriteMovie,
      'idMovie': id,
      'movieTitle': title,
      'movieReleaseDate': year.toString(),
      'movieCategory': genres.isNotEmpty ? genres[0] : '',
      'movieGenre': genres,
      'movieRating': rating.toString(),
      'imageCover': coverImage,
      'availableDownloadLinks': torrents.map((t) => t.url).toList(),
    };
  }
}
