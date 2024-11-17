class Torrent {
  final String quality;
  final String size;
  final String url;

  Torrent({
    required this.quality,
    required this.size,
    required this.url,
  });

  factory Torrent.fromJson(Map<String, dynamic> json) {
    return Torrent(
      quality: json['quality'],
      size: json['size'],
      url: json['url'],
    );
  }
}
