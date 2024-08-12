class Mygptrainer {
  Mygptrainer({
    required this.image,
    required this.name,
    required this.about,
    required this.createdAt,
    required this.lastActive,
    required this.id,
    required this.email,
    required this.pushToken,
    required this.isonline,
  });
  late String image;
  late String name;
  late String about;
  late String createdAt;
  late String lastActive;
  late String id;
  late String email;
  late String pushToken;
  late bool isonline;

  Mygptrainer.fromJson(Map<String, dynamic> json) {
    image = json['image'] ?? '';
    name = json['name'] ?? '';
    about = json['about'] ?? '';
    createdAt = json['created_at'] ?? '';
    lastActive = json['last_active'] ?? '';
    id = json['id'] ?? '';
    email = json['email'] ?? '';
    pushToken = json['push_token'] ?? '';
    isonline = json['is_online'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['image'] = image;
    data['name'] = name;
    data['about'] = about;
    data['created_at'] = createdAt;
    data['last_active'] = lastActive;
    data['id'] = id;
    data['email'] = email;
    data['push_token'] = pushToken;
    data['is_online'] = isonline;
    return data;
  }
}
