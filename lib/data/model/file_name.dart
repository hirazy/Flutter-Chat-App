class FileName{
  late String name;

  FileName({required this.name});

  FileName.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? "";
  }
}