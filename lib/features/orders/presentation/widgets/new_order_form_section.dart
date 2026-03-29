import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';
import 'package:kimo_clean/features/orders/presentation/widgets/new_order_items_card.dart';
import 'package:kimo_clean/features/orders/presentation/widgets/new_order_submit_button.dart';

class NewOrderFormSection extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController notesController;
  final String customerCode;
  final String lookupSuggestion;
  final bool isLookupLoading;
  final ValueChanged<String> onPhoneChanged;
  final String Function(String) digitsOnly;
  final VoidCallback onSavePressed;

  const NewOrderFormSection({
    super.key,
    required this.phoneController,
    required this.nameController,
    required this.addressController,
    required this.notesController,
    required this.customerCode,
    required this.lookupSuggestion,
    required this.isLookupLoading,
    required this.onPhoneChanged,
    required this.digitsOnly,
    required this.onSavePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: phoneController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 11,
          onChanged: onPhoneChanged,
          decoration: const InputDecoration(
            labelText: AppStrings.phoneLabel,
            hintText: AppStrings.lookupPhoneFieldHint,
            prefixIcon: Icon(Icons.phone),
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
        if (isLookupLoading) ...[
          const SizedBox(height: 6),
          const LinearProgressIndicator(minHeight: 3),
        ],
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: lookupSuggestion.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  key: ValueKey(lookupSuggestion),
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    lookupSuggestion,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
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
        const SizedBox(height: 12),
        InputDecorator(
          decoration: const InputDecoration(
            labelText: AppStrings.customerCodeLabel,
            prefixIcon: Icon(Icons.badge_outlined),
          ),
          child: Text(
            customerCode.isEmpty
                ? AppStrings.customerCodeAutoGenerate
                : customerCode,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 24),
        const NewOrderItemsCard(),
        const SizedBox(height: 16),
        TextFormField(
          controller: notesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: AppStrings.notesOptionalLabel,
            prefixIcon: Icon(Icons.notes),
          ),
        ),
        const SizedBox(height: 24),
        NewOrderSubmitButton(onPressed: onSavePressed),
        const SizedBox(height: 16),
      ],
    );
  }
}
