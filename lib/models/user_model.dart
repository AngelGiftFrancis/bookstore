class UserAccount {
  String name;
  String email;
  String password;
  String phoneNumber;
  String shippingAddress;
  String paymentMethod;
  bool isAdmin;

  UserAccount({
    required this.name,
    required this.email,
    required this.password,
    this.phoneNumber = '',
    this.shippingAddress = '',
    this.paymentMethod = '',
    this.isAdmin = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'shippingAddress': shippingAddress,
      'paymentMethod': paymentMethod,
      'isAdmin': isAdmin,
    };
  }

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      shippingAddress: json['shippingAddress'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
    );
  }
}

