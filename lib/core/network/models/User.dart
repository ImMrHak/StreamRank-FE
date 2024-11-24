
import 'package:streamrank/core/network/models/FavoriteMovie.dart';

class User {
  int? idUser;
  String userName;
  String password;
  String accountType;
  String email;
  String firstName;
  String lastName;
  DateTime dateOfBirth;
  bool isAdmin;
  Set<FavoriteMovie> favoriteMovies;

  User({
    this.idUser,
    required this.userName,
    required this.password,
    required this.accountType,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.isAdmin = false,
    required this.favoriteMovies,
  });

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'idUser': idUser,
      'userName': userName,
      'password': password,
      'accountType': accountType,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(), // Convert DateTime to string
      'isAdmin': isAdmin,
      'favoriteMovies': favoriteMovies.map((movie) => movie.toJson()).toList(),
    };
  }

  // Convert JSON to Dart object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['idUser'],
      userName: json['userName'],
      password: json['password'],
      accountType: json['accountType'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      isAdmin: json['isAdmin'],
      favoriteMovies: (json['favoriteMovies'] as List)
          .map((movieJson) => FavoriteMovie.fromJson(movieJson))
          .toSet(),
    );
  }

  // Convert Dart object to string representation
  @override
  String toString() {
    return 'User{idUser: $idUser, userName: $userName, email: $email, firstName: $firstName, lastName: $lastName, isAdmin: $isAdmin}';
  }
}