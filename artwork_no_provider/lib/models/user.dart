class User {
  // TODO [ADD]: Thêm field mới vào đây
  // Ví dụ: final String? phone;
  // Ví dụ: final String? avatarUrl;
  // [REASON] Để lưu trữ giá trị của field mới trong object
  // [IMPACT] Nếu không thêm, model sẽ không có field mới → lỗi khi truy xuất
  final int? id;
  final String username;
  final String email;
  final String password;
  final String createdAt;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.createdAt,
    // TODO [ADD]: Thêm parameter mới vào constructor
    // Ví dụ: required this.phone,
    // Ví dụ: this.avatarUrl,
    // [REASON] Để khởi tạo object với field mới
    // [IMPACT] Nếu không thêm, không thể tạo object với field mới
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      createdAt: json['createdAt'],
      // TODO [ADD]: Map field mới từ JSON
      // Ví dụ: phone: json['phone'],
      // Ví dụ: avatarUrl: json['avatarUrl'],
      // [REASON] Để deserialize dữ liệu từ database/json thành object
      // [IMPACT] Nếu không thêm, field mới sẽ luôn null khi đọc từ DB
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password': password,
      'createdAt': createdAt,
      // TODO [ADD]: Map field mới sang JSON
      // Ví dụ: 'phone': phone,
      // Ví dụ: 'avatarUrl': avatarUrl,
      // [REASON] Để serialize object thành JSON lưu vào database
      // [IMPACT] Nếu không thêm, field mới sẽ không được lưu vào DB
    };
  }
}