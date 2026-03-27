import 'package:flutter/material.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';

class NewOrderCustomerSection extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final bool isLoadingPhone;
  final ValueChanged<String> onPhoneChanged;
  final String Function(String) digitsOnly;

  const NewOrderCustomerSection({
    super.key,
    required this.phoneController,
    required this.nameController,
    required this.addressController,
    required this.isLoadingPhone,
    required this.onPhoneChanged,
    required this.digitsOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          onChanged: onPhoneChanged,
          decoration: InputDecoration(
            labelText: AppStrings.phoneLabel,
            prefixIcon: const Icon(Icons.phone),
            suffixIcon: isLoadingPhone
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          validator: (value) {
            final normalizedPhone = digitsOnly(value ?? '');
            if (normalizedPhone.isEmpty) {
              return AppStrings.requiredValidation;
            }
            if (normalizedPhone.length != 11) {
              return AppStrings.phoneLengthValidation;
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: AppStrings.customerNameLabel,
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) => (value == null || value.isEmpty)
              ? AppStrings.requiredValidation
              : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: addressController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: AppStrings.addressLabel,
            prefixIcon: Icon(Icons.location_on),
          ),
          validator: (value) => (value == null || value.isEmpty)
              ? AppStrings.requiredValidation
              : null,
        ),
      ],
    );
  }
}
