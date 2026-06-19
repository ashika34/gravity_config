class DesignVariant {
  final int id;
  final String name;
  final String colorCode;
  final String image;
  final int sortOrder;

  DesignVariant({
    required this.id,
    required this.name,
    required this.colorCode,
    required this.image,
    required this.sortOrder,
  });

  factory DesignVariant.fromJson(Map<String, dynamic> json) {
    return DesignVariant(
      id: json['id'] as int,
      name: json['name'] as String,
      colorCode: json['color_code'] as String,
      image: json['image'] as String,
      sortOrder: json['sort_order'] as int,
    );
  }
}

class DesignLayer {
  final int id;
  final String name;
  final int sortOrder;
  final List<DesignVariant> variants;

  DesignLayer({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.variants,
  });

  factory DesignLayer.fromJson(Map<String, dynamic> json) {
    final variantsJson = json['variants'] as List<dynamic>;
    return DesignLayer(
      id: json['id'] as int,
      name: json['name'] as String,
      sortOrder: json['sort_order'] as int,
      variants: variantsJson
          .map((v) => DesignVariant.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SeatDesignDetail {
  final int id;
  final String nameEn;
  final String nameAr;
  final String image;
  final String? baseImage;
  final String status;
  final String currency;
  final String type;
  final String createdAt;
  final List<DesignLayer> layers;

  SeatDesignDetail({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.image,
    this.baseImage,
    required this.status,
    required this.currency,
    required this.type,
    required this.createdAt,
    required this.layers,
  });

  factory SeatDesignDetail.fromJson(Map<String, dynamic> json) {
    final layersJson = json['layers'] as List<dynamic>? ?? [];
    return SeatDesignDetail(
      id: json['id'] as int,
      nameEn: json['name_en'] as String,
      nameAr: json['name_ar'] as String,
      image: json['image'] as String,
      baseImage: json['base_image'] as String?,
      status: json['status'] as String,
      currency: json['currency'] as String,
      type: json['type'] as String,
      createdAt: json['created_at'] as String,
      layers: layersJson
          .map((l) => DesignLayer.fromJson(l as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
    );
  }
}
