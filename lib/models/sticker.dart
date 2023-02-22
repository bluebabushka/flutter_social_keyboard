class Sticker {
  late String category;
  late String assetUrl;
  int width;
  int height;
  int size;

  Sticker({
    required this.assetUrl,
    required this.category,
    this.width = 0,
    this.height = 0,
    this.size = 0,
  });

  static List<Sticker> listFromJson(
      list, category, {
        int width = 0,
        int height = 0,
        int size = 0
      }) =>
      List<Sticker>.from(list.map((x) {
        x = {
          'assetUrl': x,
          'category': category,
          'width': width,
          'height': height,
          'size': size
        };
        return Sticker.fromJson(x);
      }));

  static Sticker fromJson(dynamic json) {
    return Sticker(
      assetUrl: json["assetUrl"],
      category: json['category'],
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      size: json['size'] ?? 0
    );
  }

  Map<String, dynamic> toJson() => {
        'assetUrl': assetUrl,
        'category': category,
        'width': width,
        'height': height,
        'size': size
      };
}
