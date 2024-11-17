class UserSignUpDTO {
  final String firstName;
  final String lastName;
  final String email;
  final String userName;
  final String password;
  final DateTime dateOfBirth;

  UserSignUpDTO({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.userName,
    required this.password,
    required this.dateOfBirth,
  });

  factory UserSignUpDTO.fromFormData(Map<String, dynamic> formData) {
    return UserSignUpDTO(
      firstName: formData['firstName'],
      lastName: formData['lastName'],
      email: formData['email'],
      userName: formData['userName'],
      password: formData['password'],
      dateOfBirth: DateTime.parse(formData['dateOfBirth'].toString()),
    );
  }

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'userName': userName,
      'password': password,
      'dateOfBirth': dateOfBirth.toIso8601String(),
    };
  }
}
