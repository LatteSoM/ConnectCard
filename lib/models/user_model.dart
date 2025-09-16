import 'package:connect_card/screens/visit_card_designer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

final baseUrl = dotenv.env['BASE_URL'];

class User {
  final String id;
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
      id: json['id'] ?? '',
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
    String? id,
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
      id: '',
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
  final String id;
  final String? avatar;
  final String fullname;
  final String? company;
  final String? position;
  final String? about;
  final String? userId;
  final List<ContactInfo> contactInfos;
  final List<LinkWidget> linkWidgets;
  final List<CardElement> elements;
  final String? template;

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
    required this.elements,
    this.template,
  });

  factory BusinessCard.fromJson(Map<String, dynamic> json) {
    return BusinessCard(
      id: json['id'] ?? '',
      avatar: json['avatar'] as String?,
      fullname: json['fullname'] as String? ?? 'No name',
      company: json['company'] as String?,
      position: json['position'] as String?,
      about: json['about'] as String?,
      userId: json['user_id'] as String?,
      contactInfos: (json['contact_infos'] as List<dynamic>?)
          ?.map((e) => ContactInfo.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      linkWidgets: (json['link_widgets'] as List<dynamic>?)
          ?.map((e) => LinkWidget.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      elements: (json['elements'] as List<dynamic>?)
          ?.map((e) => CardElement.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      template: json['template'] as String?,
    );
  }
}

class CardElement {
  final String type;
  final Matrix4 matrix;
  final double rotationAngle;
  final double scaleFactor;
  final double width;
  final double height;
  final String? color;
  final String? text;
  final double? fontSize;
  final double? baseFontSize;
  final String? fontFamily;
  final String? fontWeight;
  final String? textColor;
  final String? shapeType;
  final String? imageUrl;
  final double imageOpacity;
  final String? clipType;
  final String linkType;
  final String? backgroundLinkColor;

  CardElement({
    required this.type,
    required this.matrix,
    required this.rotationAngle,
    required this.scaleFactor,
    required this.width,
    required this.height,
    this.color,
    this.text,
    this.fontSize,
    this.baseFontSize,
    this.fontFamily,
    this.fontWeight,
    this.textColor,
    this.shapeType,
    this.imageUrl,
    required this.imageOpacity,
    this.clipType,
    required this.linkType,
    this.backgroundLinkColor,
  });

  factory CardElement.fromJson(Map<String, dynamic> json) {
    Matrix4 parseMatrix(String? matrixString) {
      if (matrixString == null) {
        return Matrix4.identity();
      }

      try {
        final cleanedString = matrixString.replaceAll('[', '').replaceAll(']', '');
        final values = cleanedString.split(',').map((e) => double.parse(e.trim())).toList();
        
        return Matrix4.fromList(values);
      } catch (e) {
        print('Error parsing matrix: $e');
        return Matrix4.identity();
      }
    }

    return CardElement(
      type: json['type'] as String? ?? '',
      matrix: parseMatrix(json['matrix'] as String?),
      rotationAngle: (json['rotation_angle'] as num?)?.toDouble() ?? 0.0,
      scaleFactor: (json['scale_factor'] as num?)?.toDouble() ?? 1.0,
      width: (json['width'] as num?)?.toDouble() ?? 0.0,
      height: (json['height'] as num?)?.toDouble() ?? 0.0,
      color: json['color'] as String?,
      text: json['text'] as String?,
      fontSize: (json['font_size'] as num?)?.toDouble(),
      baseFontSize: (json['base_font_size'] as num?)?.toDouble(),
      fontFamily: json['font_family'] as String?,
      fontWeight: json['font_weight'] as String?,
      textColor: json['text_color'] as String?,
      shapeType: json['shape_type'] as String?,
      imageUrl: json['image_url'] as String?,
      imageOpacity: (json['image_opacity'] as num?)?.toDouble() ?? 1.0,
      clipType: json['clip_type'] as String? ?? '',
      linkType: json['link_type'] as String? ?? '',
      backgroundLinkColor: json['background_link_color'] as String?,
    );
  }

  Color parseColor(String hexColor) {
    hexColor = hexColor.replaceFirst('#', '');
    int colorValue = int.parse(hexColor, radix: 16);
    return Color(colorValue);
  }

    final Map<String, FontWeight> fontWeightMap = {
    'normal': FontWeight.normal,
    'bold': FontWeight.bold,
    'w100': FontWeight.w100,
    'w200': FontWeight.w200,
    'w300': FontWeight.w300,
    'w400': FontWeight.w400,
    'w500': FontWeight.w500,
    'w600': FontWeight.w600,
    'w700': FontWeight.w700,
    'w800': FontWeight.w800,
    'w900': FontWeight.w900,
  };

  EditableElement convertCardElementToEditableElement() {
    return EditableElement(
      type: ElementType.values.firstWhere((e) => e.name == type),
      matrix: matrix,
      rotationAngle: rotationAngle,
      scaleFactor: scaleFactor,
      width: width,
      height: height,
      color: color != null ? parseColor(color!) : Colors.black,
      text: text,
      fontSize: fontSize,
      fontFamily: fontFamily ?? 'Roboto',
      fontWeight: fontWeightMap[fontWeight!] ?? FontWeight.normal,
      textColor: textColor != null ? parseColor(textColor!) : Colors.black,
      shapeType: shapeType != null
      ? ShapeType.values.firstWhere((e) => e.name == shapeType)
      : null,
      imageProvider: type == 'image'
      ? NetworkImage('$baseUrl${imageUrl!}')
      : null,
      imageUrl: imageUrl,
      imageOpacity: imageOpacity,
      clipType: ClipType.values.firstWhere((e) => e.name == clipType),
      linkType: LinkType.values.firstWhere((e) => e.name == linkType),
      backgroundLinkColor: backgroundLinkColor != null ? parseColor(backgroundLinkColor!) : const Color(0xFF424242),
      );
  }

}

class ContactInfo {
  final String id;
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
      id: json['id'] ?? '',
      icon: json['icon'] as String?,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
    );
  }
}

class LinkWidget {
  final String id;
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
      id: json['id'] ?? '',
      link: json['link'] as String? ?? '',
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      name: json['name'] as String? ?? '',
    );
  }
}

class Event {
  final String id;
  final String date;
  final String name;
  final String place;
  late final String formattedDate;

  Event({
    required this.id,
    required this.date,
    required this.name,
    required this.place,
  }) {
    formattedDate = _formatDate(date);
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      date: json['date'],
      name: json['name'],
      place: json['place'],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dateTime = DateTime.parse(isoDate);
      return DateFormat('dd MMMM yyyy').format(dateTime);
    } catch (e) {
      return isoDate;
    }
  }
}

class Contact {
  final String id;
  final String cardId;
  final String userId;
  final String? eventId;
  final BusinessCard? card;
  final User user;
  final Event? event;

  Contact({
    required this.id,
    required this.cardId,
    required this.userId,
    this.eventId,
    this.card,
    required this.user,
    this.event,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      cardId: json['card_id'],
      userId: json['user_id'],
      eventId: json['event_id'],
      card: json['card'] != null ? BusinessCard.fromJson(json['card']) : null,
      user: User.fromJson(json['user']),
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
    );
  }
}

class StatCard{
  final String cardId;
  final int totalViews;
  final int totalShares;
  final int totalAddToContacts;
  final double conversionRate;
  final ViewsByDevice viewsByDevice;
  final List<PopularLinks> popularLinks;
  final TopActions topActions;

  StatCard({
    required this.cardId,
    required this.totalViews,
    required this.totalShares,
    required this.totalAddToContacts,
    required this.conversionRate,
    required this.viewsByDevice,
    required this.popularLinks,
    required this.topActions,
  });

  factory StatCard.fromJson(Map<String, dynamic> json) {
    return StatCard(
      cardId: json['card_id'],
      totalViews: json['total_views'],
      totalShares: json['total_shares'],
      totalAddToContacts: json['total_add_to_contacts'],
      conversionRate: json['conversion_rate'],
      viewsByDevice: ViewsByDevice.fromJson(json['views_by_device']),
      popularLinks: (json['popular_links'] as List)
      .map((item) => PopularLinks.fromJson(item))
      .toList(),
      topActions: TopActions.fromJson(json['top_actions']),
    );
  }

  StatCard.empty()
      : cardId = '',
        totalViews = 0,
        totalShares = 0,
        totalAddToContacts = 0,
        conversionRate = 0.0,
        viewsByDevice = ViewsByDevice(desktop: 0, mobile: 0, tablet: 0),
        popularLinks = [],
        topActions = TopActions(
          view: 0,
          linkClick: 0,
          share: 0,
          addToContacts: 0,
        );
}

class ViewsByDevice {
  final int desktop;
  final int mobile;
  final int tablet;

  ViewsByDevice({
    required this.desktop,
    required this.mobile,
    required this.tablet,
  });

  factory ViewsByDevice.fromJson(Map<String, dynamic> json) {
    return ViewsByDevice(
      desktop: json['desktop'],
      mobile: json['mobile'],
      tablet: json['tablet']
    );
  }
}

class PopularLinks {
  final String linkWidgetId;
  final String name;
  final int clicks;

  PopularLinks({
    required this.linkWidgetId,
    required this.name,
    required this.clicks,
  });

  factory PopularLinks.fromJson(Map<String, dynamic> json) {
    return PopularLinks(
      linkWidgetId: json['link_widget_id'],
      name: json['name'],
      clicks: json['clicks'],
    );
  }
}

class TopActions {
  final int view;
  final int linkClick;
  final int share;
  final int addToContacts;

  TopActions({
    required this.view,
    required this.linkClick,
    required this.share,
    required this.addToContacts,
  });

  factory TopActions.fromJson(Map<String, dynamic> json) {
    return TopActions(
      view: json['view'],
      linkClick: json['link_click'],
      share: json['share'],
      addToContacts: json['add_to_contacts'],
    );
  }
}