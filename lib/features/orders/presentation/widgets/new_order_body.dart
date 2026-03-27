import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kimo_clean/core/constants/app_strings.dart';
import 'package:kimo_clean/core/utils/whatsapp_utils.dart';
import 'package:kimo_clean/features/orders/cubit/new_order_cubit.dart';
import 'package:kimo_clean/features/orders/cubit/new_order_state.dart';
import 'package:kimo_clean/features/orders/presentation/widgets/new_order_customer_section.dart';
import 'package:kimo_clean/features/orders/presentation/widgets/new_order_items_card.dart';
import 'package:kimo_clean/features/orders/presentation/widgets/new_order_submit_button.dart';
import 'package:kimo_clean/core/theme/app_colors.dart';

class NewOrderBody extends StatefulWidget {
  const NewOrderBody({super.key});

  @override
  State<NewOrderBody> createState() => _NewOrderBodyState();
}

class _NewOrderBodyState extends State<NewOrderBody> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<NewOrderCubit>().saveOrder(
        phone: _phoneController.text,
        name: _nameController.text,
        address: _addressController.text,
        notes: _notesController.text,
      );
    }
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _listenToState(BuildContext context, NewOrderState state) async {
    if (state is NewOrderPhoneLookupSuccess) {
      _nameController.text = state.customerName;
      _addressController.text = state.address;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(AppStrings.customerDataFetchedSuccess),
          backgroundColor: AppColors.successDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (state is NewOrderValidationError || state is NewOrderSaveError) {
      final message = state is NewOrderValidationError
          ? state.message
          : (state as NewOrderSaveError).message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (state is! NewOrderSaveSuccess) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<NewOrderCubit>();
    final primaryColor = Theme.of(context).colorScheme.primary;

    try {
      await WhatsAppUtils.launch(
        serialNumber: state.serialNumber,
        customerName: state.customerName,
        phone: state.phone,
        address: state.address,
        items: state.items,
        totalPieces: state.totalPieces,
        notes: state.notes,
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.toString())));
    }

    _phoneController.clear();
    _nameController.clear();
    _addressController.clear();
    _notesController.clear();
    cubit.reset();

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${AppStrings.saveAndSendSuccessPrefix} ${state.serialNumber})',
        ),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewOrderCubit, NewOrderState>(
      listener: _listenToState,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocSelector<NewOrderCubit, NewOrderState, bool>(
                selector: (state) => state is NewOrderPhoneLookupLoading,
                builder: (context, isLoadingPhone) {
                  return NewOrderCustomerSection(
                    phoneController: _phoneController,
                    nameController: _nameController,
                    addressController: _addressController,
                    isLoadingPhone: isLoadingPhone,
                    onPhoneChanged: (value) {
                      if (_digitsOnly(value).length == 11) {
                        FocusScope.of(context).unfocus();
                        context.read<NewOrderCubit>().lookupCustomer(value);
                      }
                    },
                    digitsOnly: _digitsOnly,
                  );
                },
              ),
              const SizedBox(height: 24),
              const NewOrderItemsCard(),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: AppStrings.notesOptionalLabel,
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),
              NewOrderSubmitButton(onPressed: _onSavePressed),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
