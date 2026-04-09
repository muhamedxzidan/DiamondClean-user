import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diamond_clean_user/core/constants/app_strings.dart';
import 'package:diamond_clean_user/core/utils/whatsapp_utils.dart';
import 'package:diamond_clean_user/features/orders/cubit/new_order_cubit.dart';
import 'package:diamond_clean_user/features/orders/cubit/new_order_state.dart';

class NewOrderUiSession {
  bool isAutofilled = false;
  String? pendingCodeLookup;
}

String buildLookupSuggestion(NewOrderState state, {String? pendingCodeLookup}) {
  if (state is NewOrderPhoneLookupLoading) {
    if (pendingCodeLookup != null && pendingCodeLookup.isNotEmpty) {
      return '${AppStrings.lookupSearchingByCodePrefix} DC-$pendingCodeLookup';
    }
    return AppStrings.lookupSearchingByPhone;
  }

  if (state is NewOrderPhoneLookupSuccess) {
    return '${AppStrings.lookupFoundCustomerPrefix} ${state.customerCode}';
  }

  if (state is NewOrderCustomerLookupNotFound) {
    if (state.query.length == 11) {
      return AppStrings.lookupNotFoundByPhone;
    }
    return '${AppStrings.lookupNotFoundByCodePrefix} DC-${state.query}';
  }

  return '';
}

Future<void> handleNewOrderState({
  required BuildContext context,
  required NewOrderState state,
  required TextEditingController phoneController,
  required TextEditingController nameController,
  required TextEditingController addressController,
  required TextEditingController notesController,
  required NewOrderUiSession uiSession,
}) async {
  if (state is NewOrderPhoneLookupSuccess) {
    if (state.phone.isNotEmpty && state.phone != phoneController.text) {
      phoneController.text = state.phone;
    }

    nameController.text = state.customerName;
    addressController.text = state.address;
    uiSession.isAutofilled = true;
    uiSession.pendingCodeLookup = null;
    return;
  }

  if (state is NewOrderCustomerLookupNotFound) {
    uiSession.isAutofilled = false;
    uiSession.pendingCodeLookup = null;
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
      customerCode: state.customerCode,
      customerName: state.customerName,
      phone: state.phone,
      address: state.address,
      items: state.items,
      totalPieces: state.totalPieces,
      notes: state.notes,
    );
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(e.toString())));
  }

  phoneController.clear();
  nameController.clear();
  addressController.clear();
  notesController.clear();
  uiSession.isAutofilled = false;
  uiSession.pendingCodeLookup = null;
  cubit.reset();

  messenger.showSnackBar(
    SnackBar(
      content: Text(
        '${AppStrings.saveAndSendSuccessPrefix} ${state.serialNumber}) - ${AppStrings.customerCodeLabel}: ${state.customerCode}',
      ),
      backgroundColor: primaryColor,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
