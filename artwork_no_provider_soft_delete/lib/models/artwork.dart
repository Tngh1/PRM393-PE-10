class Artwork {
  // TODO [ADD]: Thêm field mới vào đây
  // Ví dụ: final double? price;
  // Ví dụ: final String? imageUrl;
  // [REASON] Để lưu trữ giá trị của field mới trong object
  // [IMPACT] Nếu không thêm, model sẽ không có field mới → lỗi khi truy xuất
  final int? id;
  final String title;
  final String artist;
  final int year;
  final String category;
  final String description;
  final int createdBy;
  final bool isDeleted;
  final String? deletedAt;

  Artwork({
    this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.category,
    required this.description,
    required this.createdBy,
    this.isDeleted = false,
    this.deletedAt,
    // TODO [ADD]: Thêm parameter mới vào constructor
    // Ví dụ: this.price,
    // Ví dụ: this.imageUrl,
    // [REASON] Để khởi tạo object với field mới
    // [IMPACT] Nếu không thêm, không thể tạo object với field mới
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      year: json['year'],
      category: json['category'],
      description: json['description'],
      createdBy: json['createdBy'],
      isDeleted: json['isDeleted'] == 1 || json['isDeleted'] == true,
      deletedAt: json['deletedAt'],
      // TODO [ADD]: Map field mới từ JSON
      // Ví dụ: price: json['price']?.toDouble(),
      // Ví dụ: imageUrl: json['imageUrl'],
      // [REASON] Để deserialize dữ liệu từ database/json thành object
      // [IMPACT] Nếu không thêm, field mới sẽ luôn null khi đọc từ DB
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'year': year,
      'category': category,
      'description': description,
      'createdBy': createdBy,
      'isDeleted': isDeleted ? 1 : 0,
      'deletedAt': deletedAt,
      // TODO [ADD]: Map field mới sang JSON
      // Ví dụ: 'price': price,
      // Ví dụ: 'imageUrl': imageUrl,
      // [REASON] Để serialize object thành JSON lưu vào database
      // [IMPACT] Nếu không thêm, field mới sẽ không được lưu vào DB
    };
  }
}
