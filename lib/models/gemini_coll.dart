class Gemini {
  Gemini({
    required this.urlImage,
  });

  late String urlImage;

  Gemini.fromJson(Map<String, dynamic> json) {
    urlImage = json['url_image'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['url_image'] = urlImage;
    return data;
  }
}
