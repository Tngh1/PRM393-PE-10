// ============================================================
// 💾 HƯỚNG DẪN THÊM TRƯỜNG MỚI VÀO ARTWORK MODEL
// ============================================================
// KHI THÊM TRƯỜNG MỚI VÀO ARTWORK (KHÔNG PHẢI isDeleted/deletedAt):
//
// 1. FIELD - Khai báo field:
//    Thêm: final type? fieldName;
//    (Đặt ở cuối, trước isDeleted)
//
// 2. CONSTRUCTOR - Thêm parameter:
//    Thêm: this.fieldName,
//    (Đặt ở cuối, trước isDeleted)
//
// 3. FROM_JSON - Deserialize:
//    Thêm: fieldName: json['fieldName'],
//    (Đặt ở cuối, trước isDeleted)
//
// 4. TO_JSON - Serialize:
//    Thêm: 'fieldName': fieldName,
//    (Đặt ở cuối, trước isDeleted)
//
// ⚠️ LƯU Ý: isDeleted và deletedAt là trường SOFT DELETE, KHÔNG thay đổi
// ============================================================

class Artwork {
  // TODO [ADD]: Thêm field mới vào đây (KHÔNG phải isDeleted/deletedAt)
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

  // ============================================================
  // 🔐 SOFT DELETE FIELDS - KHÔNG THAY ĐỔI
  // ============================================================
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
    // TODO [ADD]: Thêm parameter mới vào constructor (KHÔNG phải isDeleted/deletedAt)
    // Ví dụ: this.price,
    // Ví dụ: this.imageUrl,
    // [REASON] Để khởi tạo object với field mới
    // [IMPACT] Nếu không thêm, không thể tạo object với field mới

    // 🔐 SOFT DELETE - Mặc định: chưa xóa
    this.isDeleted = false,
    this.deletedAt,
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
      // TODO [ADD]: Map field mới từ JSON (KHÔNG phải isDeleted/deletedAt)
      // Ví dụ: price: json['price']?.toDouble(),
      // Ví dụ: imageUrl: json['imageUrl'],
      // [REASON] Để deserialize dữ liệu từ database/json thành object
      // [IMPACT] Nếu không thêm, field mới sẽ luôn null khi đọc từ DB

      // 🔐 SOFT DELETE - Tự động parse
      isDeleted: json['isDeleted'] == 1 || json['isDeleted'] == true,
      deletedAt: json['deletedAt'],
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
      // TODO [ADD]: Map field mới sang JSON (KHÔNG phải isDeleted/deletedAt)
      // Ví dụ: 'price': price,
      // Ví dụ: 'imageUrl': imageUrl,
      // [REASON] Để serialize object thành JSON lưu vào database
      // [IMPACT] Nếu không thêm, field mới sẽ không được lưu vào DB

      // 🔐 SOFT DELETE - Tự động serialize
      'isDeleted': isDeleted ? 1 : 0,
      'deletedAt': deletedAt,
    };
  }
}
