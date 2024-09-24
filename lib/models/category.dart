// ignore_for_file: public_member_api_docs, sort_constructors_first
class Category {

  int? kategoriID;
  String? kategoriBaslik;

  Category(this.kategoriBaslik);

  Category.withID(this.kategoriID, this.kategoriBaslik);

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{};
    map['kategoriId'] = kategoriID;
    map['kategoriBaslik'] = kategoriBaslik;
    return map;
  }

  Category.fromMap(Map<String, dynamic> map){
    this.kategoriID = map['kategoriID'];
    this.kategoriBaslik = map['kategoriBaslik'];
  }

  @override
  String toString() {
    return 'Kategori{kategoriID: $kategoriID, kategoriBaslik: $kategoriBaslik}';
  }



}
