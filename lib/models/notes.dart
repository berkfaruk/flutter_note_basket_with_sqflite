// ignore_for_file: public_member_api_docs, sort_constructors_first
class Notes {
  int? notID;
  int? kategoriID;
  String? kategoriBaslik;
  String? notBaslik;
  String? notIcerik;
  String? notTarih;
  int? notOncelik;

  Notes(
    this.kategoriID,
    this.notBaslik,
    this.notIcerik,
    this.notTarih,
    this.notOncelik,
  );

  Notes.withID(this.notID, this.kategoriID, this.notBaslik, this.notIcerik,
      this.notTarih, this.notOncelik);

  Map<String, dynamic> toMap(){
    var map = <String, dynamic>{};
    map['notID'] = notID;
    map['kategoriID'] = kategoriID;
    map['notBaslik'] = notBaslik;
    map['notIcerik'] = notIcerik;
    map['notTarih'] = notTarih;
    map['notOncelik'] = notOncelik;

    return map;
  }

  Notes.fromMap(Map<String, dynamic> map){
    this.notID = map['notID'];
    this.kategoriID = map['kategoriID'];
    this.kategoriBaslik = map['kategoriBaslik'];
    this.notBaslik = map['notBaslik'];
    this.notIcerik = map['notIcerik'];
    this.notTarih = map['notTarih'];
    this.notOncelik = map['notOncelik'];
  }

}
