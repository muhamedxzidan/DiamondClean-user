class CustomerLookupModel {
  final String phone;
  final String name;
  final String address;
  final String customerCode;
  final int? customerSerial;

  const CustomerLookupModel({
    required this.phone,
    required this.name,
    required this.address,
    required this.customerCode,
    this.customerSerial,
  });

  factory CustomerLookupModel.fromFirestore(Map<String, dynamic>? data) {
    final rawData = data ?? <String, dynamic>{};
    return CustomerLookupModel(
      phone:
          (rawData['phoneNumber'] as String?) ??
          (rawData['phone'] as String?) ??
          '',
      name: rawData['name'] as String? ?? 'Unknown',
      address: rawData['address'] as String? ?? 'Unknown',
      customerCode: rawData['customerCode'] as String? ?? 'Undefined',
      customerSerial: (rawData['customerSerial'] as num?)?.toInt() ?? 0,
    );
  }
}
