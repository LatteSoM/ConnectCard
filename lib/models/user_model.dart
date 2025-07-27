class User {
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
  final bool consentGiven;
  final DateTime? consentTimestamp;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.consentGiven = false,
    this.consentTimestamp,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      login: json['login'],
      avatar: json['avatar'],
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      isPremiumUser: json['is_premium_user'] ?? false,
      isTelegramAuth: json['telegram_authorized'] ?? false,
      isVkAuth: json['vk_authorized'] ?? false,
      hasPassword: json['password'] != null,
      consentGiven: json['consent_given'] ?? false,
      consentTimestamp: json['consent_timestamp'] != null 
          ? DateTime.parse(json['consent_timestamp']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
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
      'consent_given': consentGiven,
      'consent_timestamp': consentTimestamp?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
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
    bool? consentGiven,
    DateTime? consentTimestamp,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<BusinessCard>? businessCards,
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
      consentGiven: consentGiven ?? this.consentGiven,
      consentTimestamp: consentTimestamp ?? this.consentTimestamp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
      consentGiven: false,
    );
  }
}

class BusinessCard {
  final int id;
  final String? avatar;
  final String fullname;
  final String? company;
  final String? position;
  final String? about;
  final int? userId;
  final List<ContactInfo> contactInfos;
  final List<LinkWidget> linkWidgets;

  BusinessCard({
    required this.id,
    this.avatar,
    required this.fullname,
    this.company,
    this.position,
    this.about,
    this.userId,
    required this.contactInfos,
    required this.linkWidgets,
  });

  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      id: json['id'] as int? ?? 0,
      avatar: json['avatar'] as String?,
      fullname: json['fullname'] as String? ?? 'No name',
      company: json['company'] as String?,
      position: json['position'] as String?,
      about: json['about'] as String?,
      userId: json['user_id'] as int?,
      contactInfos: (json['contact_infos'] as List<dynamic>?)
          ?.map((e) => ContactInfo.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      linkWidgets: (json['link_widgets'] as List<dynamic>?)
          ?.map((e) => LinkWidget.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class ContactInfo {
  final int id;
  final String? icon;
  final String name;
  final String? description;

  ContactInfo({
    required this.id,
    this.icon,
    required this.name,
    this.description,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      id: json['id'] as int? ?? 0,
      icon: json['icon'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class LinkWidget {
  final int id;
  final String link;
  final String? icon;
  final String? description;
  final String name;

  LinkWidget({
    required this.id,
    required this.link,
    this.icon,
    this.description,
    required this.name,
  });

  factory LinkWidget.fromJson(Map<String, dynamic> json) {
    return LinkWidget(
      id: json['id'] as int? ?? 0,
      link: json['link'] as String? ?? '',
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      name: json['name'] as String? ?? '',
    );
  }
}