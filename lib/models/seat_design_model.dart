class SeatDesign {
  final int id;
  final String nameEn;
  final String nameAr;
  final String image;
  final String? baseImage;
  final String status;
  final String currency;
  final String type;
  final String createdAt;

  SeatDesign({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.image,
    this.baseImage,
    required this.status,
    required this.currency,
    required this.type,
    required this.createdAt,
  });

  factory SeatDesign.fromJson(Map<String, dynamic> json) {
    return SeatDesign(
      id: json['id'] as int,
      nameEn: json['name_en'] as String,
      nameAr: json['name_ar'] as String,
      image: json['image'] as String,
      baseImage: json['base_image'] as String?,
      status: json['status'] as String,
      currency: json['currency'] as String,
      type: json['type'] as String,
      createdAt: json['created_at'] as String,
    );
  }
}
