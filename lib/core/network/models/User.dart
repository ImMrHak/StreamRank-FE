import 'package:streamrank/core/network/models/FavoriteMovie.dart';

class User {
  int idUser;
  String accountType;
  String email;
  String firstName;
  String lastName;
  DateTime dateOfBirth;
  List<FavoriteMovie> favoriteMovies;
  bool enabled;
  bool accountNonExpired;
  bool credentialsNonExpired;
  bool accountNonLocked;

  User({
    required this.idUser,
    required this.accountType,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.favoriteMovies,
    required this.enabled,
    required this.accountNonExpired,
    required this.credentialsNonExpired,
    required this.accountNonLocked,
  });

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'accountType': accountType,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'favoriteMovies': favoriteMovies.map((movie) => movie.toJson()).toList(),
      'enabled': enabled,
      'accountNonExpired': accountNonExpired,
      'credentialsNonExpired': credentialsNonExpired,
      'accountNonLocked': accountNonLocked,
    };
  }

  // Convert JSON to Dart object
  factory User.fromJson(Map<String, dynamic> json) {
    var favoriteMoviesList = json['favoriteMovies'] as List;
    List<FavoriteMovie> favoriteMovies = favoriteMoviesList.map((movieJson) => FavoriteMovie.fromJson(movieJson)).toList();

    return User(
      idUser: json['idUser'],
      accountType: json['accountType'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      favoriteMovies: favoriteMovies,
      enabled: json['enabled'],
      accountNonExpired: json['accountNonExpired'],
      credentialsNonExpired: json['credentialsNonExpired'],
      accountNonLocked: json['accountNonLocked'],
    );
  }

  // Convert Dart object to string representation
  @override
  String toString() {
    return 'User{idUser: $idUser, accountType: $accountType, email: $email, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, favoriteMovies: $favoriteMovies, enabled: $enabled, accountNonExpired: $accountNonExpired, credentialsNonExpired: $credentialsNonExpired, accountNonLocked: $accountNonLocked}';
  }
}