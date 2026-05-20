import '../api/address_repositiry.dart';
import '../features/profile/models/address_model.dart';

class AddressService {
  final AddressRepository _repo = AddressRepository();

  Future<List<AddressModel>> loadAddresses(String token) async {
    return await _repo.getAddresses(token);
  }

  Future<AddressModel> createAddress(String token, AddressModel data) async {
    final addressData = {
      'street': data.street,
      'house': data.house,
      'corpus': data.corpus ?? '',
      'entrance': data.entrance ?? '',
      'floor': data.floor ?? '',
      'flat': data.flat ?? '',
      'comment': data.comment ?? '',
    };
    return await _repo.createAddress(token, addressData);
  }

  bool isAddressChanged(AddressModel? old, AddressModel current) {
    if (old == null) return true;

    return old.street != current.street ||
        old.house != current.house ||
        (old.corpus ?? '') != (current.corpus ?? '') ||
        (old.entrance ?? '') != (current.entrance ?? '') ||
        (old.floor ?? '') != (current.floor ?? '') ||
        (old.flat ?? '') != (current.flat ?? '');
  }

  AddressModel fromControllers({
    required String street,
    required String house,
    required String corpus,
    required String entrance,
    required String floor,
    required String flat,
    required String comment,
  }) {
    return AddressModel(
      id: -1,
      street: street,
      house: house,
      corpus: corpus.isEmpty ? null : corpus,
      entrance: entrance.isEmpty ? null : entrance,
      floor: floor.isEmpty ? null : floor,
      flat: flat.isEmpty ? null : flat,
      comment: comment.isEmpty ? null : comment,
      isDefault: false,
    );
  }
}
