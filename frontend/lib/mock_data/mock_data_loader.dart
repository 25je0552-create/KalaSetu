import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';
import '../core/services/mock_delay.dart';

class Product {
  final String id;
  final String name;
  final String nameEn;
  final String nameHi;
  final String artisanId;
  final String artisanName;
  final String cluster;
  final String category;
  final double price;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isGI;
  final String descriptionHi;
  final String descriptionEn;
  final List<String> materials;
  final String dimensions;
  final String imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameHi,
    required this.artisanId,
    required this.artisanName,
    required this.cluster,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.stock,
    required this.isGI,
    required this.descriptionHi,
    required this.descriptionEn,
    required this.materials,
    required this.dimensions,
    required this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      nameHi: json['nameHi'] as String,
      artisanId: json['artisanId'] as String,
      artisanName: json['artisanName'] as String,
      cluster: json['cluster'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: json['reviewCount'] as int,
      stock: json['stock'] as int,
      isGI: json['isGI'] as bool,
      descriptionHi: json['descriptionHi'] as String,
      descriptionEn: json['descriptionEn'] as String,
      materials: List<String>.from(json['materials'] ?? []),
      dimensions: json['dimensions'] as String,
      imageUrl: json['imageUrl'] as String,
    );
  }
}

class Artisan {
  final String id;
  final String name;
  final String phone;
  final String craftType;
  final String village;
  final String district;
  final String state;
  final bool isCertified;
  final String artisanCardNumber;
  final String avatarUrl;
  final String story;
  final int activeProductsCount;
  final double rating;
  final int yearsOfExperience;
  final String aadhaarNumber;
  final String? email;

  Artisan({
    required this.id,
    required this.name,
    required this.phone,
    required this.craftType,
    required this.village,
    required this.district,
    required this.state,
    required this.isCertified,
    required this.artisanCardNumber,
    required this.avatarUrl,
    required this.story,
    required this.activeProductsCount,
    required this.rating,
    required this.yearsOfExperience,
    this.aadhaarNumber = '5842-9134-8492',
    this.email = 'ramesh.prajapati@kalasetu.in',
  });

  factory Artisan.fromJson(Map<String, dynamic> json) {
    return Artisan(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      craftType: json['craftType'] as String,
      village: json['village'] as String,
      district: json['district'] as String,
      state: json['state'] as String,
      isCertified: json['isCertified'] as bool,
      artisanCardNumber: json['artisanCardNumber'] as String,
      avatarUrl: json['avatarUrl'] as String,
      story: json['story'] as String,
      activeProductsCount: json['activeProductsCount'] as int,
      rating: (json['rating'] as num).toDouble(),
      yearsOfExperience: json['yearsOfExperience'] as int,
      aadhaarNumber: (json['aadhaarNumber'] as String?) ?? '5842-9134-8492',
      email: (json['email'] as String?) ?? 'ramesh.prajapati@kalasetu.in',
    );
  }
}

class ArtisanOrder {
  final String id;
  final String orderNumber;
  final String artisanId;
  final String productName;
  final String productImage;
  final String customerName;
  final String city;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String status;
  final String statusLabelHi;
  final String statusLabelEn;
  final String placedAt;
  final String shippingDeadline;
  final String? trackingNumber;

  ArtisanOrder({
    required this.id,
    required this.orderNumber,
    required this.artisanId,
    required this.productName,
    required this.productImage,
    required this.customerName,
    required this.city,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.status,
    required this.statusLabelHi,
    required this.statusLabelEn,
    required this.placedAt,
    required this.shippingDeadline,
    this.trackingNumber,
  });

  factory ArtisanOrder.fromJson(Map<String, dynamic> json) {
    return ArtisanOrder(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      artisanId: json['artisanId'] as String,
      productName: json['productName'] as String,
      productImage: json['productImage'] as String,
      customerName: json['customerName'] as String,
      city: json['city'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String,
      statusLabelHi: json['statusLabelHi'] as String,
      statusLabelEn: json['statusLabelEn'] as String,
      placedAt: json['placedAt'] as String,
      shippingDeadline: json['shippingDeadline'] as String,
      trackingNumber: json['trackingNumber'] as String?,
    );
  }
}

class CraftFair {
  final String id;
  final String titleHi;
  final String titleEn;
  final String categoryHi;
  final String categoryEn;
  final String badgeHi;
  final String badgeEn;
  final String daysLeftHi;
  final String daysLeftEn;
  final String locationHi;
  final String locationEn;
  final String dateRangeHi;
  final String dateRangeEn;
  final String subsidyNoteHi;
  final String subsidyNoteEn;
  final String expectedVisitorsHi;
  final String expectedVisitorsEn;
  final String imageUrl;
  final bool applied;
  final bool subsidized;
  final List<String> participatingShopIds;
  final int participatingShopsCount;
  final String descriptionHi;
  final String descriptionEn;

  CraftFair({
    required this.id,
    required this.titleHi,
    required this.titleEn,
    required this.categoryHi,
    required this.categoryEn,
    required this.badgeHi,
    required this.badgeEn,
    required this.daysLeftHi,
    required this.daysLeftEn,
    required this.locationHi,
    required this.locationEn,
    required this.dateRangeHi,
    required this.dateRangeEn,
    required this.subsidyNoteHi,
    required this.subsidyNoteEn,
    required this.expectedVisitorsHi,
    required this.expectedVisitorsEn,
    required this.imageUrl,
    required this.applied,
    required this.subsidized,
    this.participatingShopIds = const [],
    this.participatingShopsCount = 0,
    this.descriptionHi = '',
    this.descriptionEn = '',
  });

  factory CraftFair.fromJson(Map<String, dynamic> json) {
    return CraftFair(
      id: json['id'] as String,
      titleHi: json['titleHi'] as String,
      titleEn: json['titleEn'] as String,
      categoryHi: json['categoryHi'] as String,
      categoryEn: json['categoryEn'] as String,
      badgeHi: json['badgeHi'] as String,
      badgeEn: json['badgeEn'] as String,
      daysLeftHi: json['daysLeftHi'] as String,
      daysLeftEn: json['daysLeftEn'] as String,
      locationHi: json['locationHi'] as String,
      locationEn: json['locationEn'] as String,
      dateRangeHi: json['dateRangeHi'] as String,
      dateRangeEn: json['dateRangeEn'] as String,
      subsidyNoteHi: json['subsidyNoteHi'] as String,
      subsidyNoteEn: json['subsidyNoteEn'] as String,
      expectedVisitorsHi: json['expectedVisitorsHi'] as String,
      expectedVisitorsEn: json['expectedVisitorsEn'] as String,
      imageUrl: json['imageUrl'] as String,
      applied: json['applied'] as bool,
      subsidized: json['subsidized'] as bool,
      participatingShopIds: List<String>.from(json['participatingShopIds'] ?? []),
      participatingShopsCount: json['participatingShopsCount'] as int? ?? (json['participatingShopIds'] != null ? (json['participatingShopIds'] as List).length : 25),
      descriptionHi: json['descriptionHi'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
    );
  }
}

class MockDataLoader {
  // Real impl later: GET /api/products
  static Future<List<Product>> loadProducts() async {
    await MockDelay.wait();
    final jsonStr = await rootBundle.loadString(AppConstants.mockProductsPath);
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((item) => Product.fromJson(item)).toList();
  }

  // Real impl later: GET /api/artisans/:id
  static Future<List<Artisan>> loadArtisans() async {
    await MockDelay.wait();
    final jsonStr = await rootBundle.loadString(AppConstants.mockArtisansPath);
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((item) => Artisan.fromJson(item)).toList();
  }

  // Real impl later: GET /api/orders
  static Future<List<ArtisanOrder>> loadOrders() async {
    await MockDelay.wait();
    final jsonStr = await rootBundle.loadString(AppConstants.mockOrdersPath);
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((item) => ArtisanOrder.fromJson(item)).toList();
  }

  // Real impl later: GET /api/fairs
  static Future<List<CraftFair>> loadFairs() async {
    await MockDelay.wait();
    final jsonStr = await rootBundle.loadString(AppConstants.mockFairsPath);
    final List<dynamic> list = jsonDecode(jsonStr);
    return list.map((item) => CraftFair.fromJson(item)).toList();
  }
}
