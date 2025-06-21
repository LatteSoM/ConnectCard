class User{
  final int id;
  final String? login;
  final String? avatar;
  final String name;
  final String? phone;
  final String? email;
  final bool isPremiumUser;
  final bool isTelegramAuth;
  final bool isVkAuth;
  final bool hasPassword;

  User({
    required this.id,
    this.login,
    this.avatar,
    required this.name,
    this.phone,
    this.email,
    required this.isPremiumUser,
    required this.isTelegramAuth,
    required this.isVkAuth,
    required this.hasPassword,
  });

  factory User.fromJson(Map<String, dynamic> json){
    return User(
      id: json['id'],
      login: json['login'],
      avatar: json['avatar'],
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      isPremiumUser: json['is_premium_user'],
      isTelegramAuth: json['telegram_authorized'],
      isVkAuth: json['vk_authorized'],
      hasPassword: json['password'] != null,
    );
  }

  Map<String, dynamic> toJson({String? password}) {
    final json = {
      'id': id,
      'login': login,
      'avatar': avatar,
      'name': name,
      'phone': phone,
      'email': email,
      'is_premium_user': isPremiumUser,
      'telegram_authorized': isTelegramAuth,
      'vk_authorized': isVkAuth,
    };

    if (password != null) {
      json['password'] = password;
    }

    return json;
  }

  User copyWith({
    int? id,
    String? login,
    String? avatar,
    String? name,
    String? phone,
    String? email,
    bool? isPremiumUser,
    bool? isTelegramAuth,
    bool? isVkAuth,
    bool? hasPassword,
  }) {
    return User(
      id: id ?? this.id,
      login: login ?? this.login,
      avatar: avatar ?? this.avatar,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isPremiumUser: isPremiumUser ?? this.isPremiumUser,
      isTelegramAuth: isTelegramAuth ?? this.isTelegramAuth,
      isVkAuth: isVkAuth ?? this.isVkAuth,
      hasPassword: hasPassword ?? this.hasPassword,
    );
  }

  factory User.empty() {
    return User(
      id: 0,
      login: null,
      avatar: null,
      name: '',
      phone: null,
      email: null,
      isPremiumUser: false,
      isTelegramAuth: false,
      isVkAuth: false,
      hasPassword: false,
    );
  }
}