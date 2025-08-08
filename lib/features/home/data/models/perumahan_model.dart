class Perumahan {
  final int id;
  final String nama;

  Perumahan({required this.id, required this.nama});

  factory Perumahan.fromJson(Map<String, dynamic> json) {
    return Perumahan(id: json['id'], nama: json['nama']);
  }
}
