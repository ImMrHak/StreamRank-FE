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

  Map<String, dynamic> toJson() {
    return {
      'quality': quality,
      'size': size,
      'url': url,
    };
  }

  @override
  String toString() {
    return 'Torrent{quality: $quality, size: $size, url: $url}';
  }
}
