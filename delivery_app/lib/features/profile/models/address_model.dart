class AddressModel {
  final int id;
  final String street;
  final String house;
  final String? corpus;
  final String? entrance;
  final String? floor;
  final String? flat;
  final String? comment;
  final bool isDefault;

  AddressModel({
    required this.id,
    required this.street,
    required this.house,
    this.corpus,
    this.entrance,
    this.floor,
    this.flat,
    this.comment,
    required this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      street: json['street'],
      house: json['house'],
      corpus: json['corpus'],
      entrance: json['entrance'],
      floor: json['floor'],
      flat: json['flat'],
      comment: json['comment'],
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'street': street,
      'house': house,
      'corpus': corpus,
      'entrance': entrance,
      'floor': floor,
      'flat': flat,
      'comment': comment,
    };
  }
}
