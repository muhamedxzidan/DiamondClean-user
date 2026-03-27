class CustomerLookupModel {
  final String name;
  final String address;
  final int? customerSerial;

  const CustomerLookupModel({
    required this.name,
    required this.address,
    this.customerSerial,
  });
}
