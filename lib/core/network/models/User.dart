
import 'package:streamrank/core/network/models/FavoriteMovie.dart';

class User {
  String userName;
  String email;
  String firstName;
  String lastName;


  User({
    required this.userName,
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  // Convert Dart object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  // Convert JSON to Dart object
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userName: json['userName'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],

    );
  }

  // Convert Dart object to string representation
  @override
  String toString() {
    return 'User{ userName: $userName, email: $email, firstName: $firstName, lastName: $lastName}';
  }
}