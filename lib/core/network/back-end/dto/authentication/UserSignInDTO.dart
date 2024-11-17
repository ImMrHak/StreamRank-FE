class UserSignInDTO {
  final String usernameOrEmail;
  final String password;

  UserSignInDTO({
    required this.usernameOrEmail,
    required this.password,
  });

  factory UserSignInDTO.fromFormData(Map<String, dynamic> formData) {
    return UserSignInDTO(
      usernameOrEmail: formData['usernameOrEmail'],
      password: formData['password'],
    );
  }

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'usernameOrEmail': usernameOrEmail,
      'password': password,
    };
  }
}
