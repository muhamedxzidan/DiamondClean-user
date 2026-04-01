import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cpc_clean_user/core/constants/app_constants.dart';
import 'package:cpc_clean_user/core/utils/phone_utils.dart';
import 'package:cpc_clean_user/features/orders/cubit/new_order_cubit.dart';
import 'package:cpc_clean_user/features/orders/cubit/new_order_state.dart';
import 'package:cpc_clean_user/features/orders/presentation/widgets/new_order_body_helpers.dart';
import 'package:cpc_clean_user/features/orders/presentation/widgets/new_order_form_section.dart';

class NewOrderBody extends StatefulWidget {
  final String? initialLookupQuery;

  const NewOrderBody({super.key, this.initialLookupQuery});

  @override
  State<NewOrderBody> createState() => _NewOrderBodyState();
}

class _NewOrderBodyState extends State<NewOrderBody> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _uiSession = NewOrderUiSession();

  @override
  void initState() {
    super.initState();
    final initialQuery = widget.initialLookupQuery?.trim();
    if (initialQuery == null || initialQuery.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final normalized = normalizePhone(initialQuery);
      if (normalized.isEmpty) return;

      if (normalized.length == AppConstants.egyptPhoneLength) {
        _phoneController.text = normalized;
        _triggerAutoLookup(normalized);
      } else {
        _uiSession.pendingCodeLookup = normalized;
        context.read<NewOrderCubit>().lookupCustomer(normalized);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _clearAutofilledCustomerData() {
    if (_uiSession.isAutofilled) {
      _nameController.clear();
      _addressController.clear();
    }
    _uiSession.isAutofilled = false;
    _uiSession.pendingCodeLookup = null;
    context.read<NewOrderCubit>().clearLookupState();
  }

  void _triggerAutoLookup(String value) {
    final digits = normalizePhone(value);
    if (digits.length != AppConstants.egyptPhoneLength) {
      _clearAutofilledCustomerData();
      return;
    }
    _uiSession.pendingCodeLookup = null;
    context.read<NewOrderCubit>().lookupCustomer(digits);
  }

  void _onPhoneChanged(String value) {
    final digits = normalizePhone(value);
    if (digits != value) {
      _phoneController
        ..text = digits
        ..selection = TextSelection.collapsed(offset: digits.length);
    }

    if (digits.length == AppConstants.egyptPhoneLength) {
      _triggerAutoLookup(digits);
      return;
    }
    _clearAutofilledCustomerData();
  }

  Future<void> _listenToState(BuildContext context, NewOrderState state) async {
    await handleNewOrderState(
      context: context,
      state: state,
      phoneController: _phoneController,
      nameController: _nameController,
      addressController: _addressController,
      notesController: _notesController,
      uiSession: _uiSession,
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
          child: BlocBuilder<NewOrderCubit, NewOrderState>(
            builder: (context, state) {
              return NewOrderFormSection(
                phoneController: _phoneController,
                nameController: _nameController,
                addressController: _addressController,
                notesController: _notesController,
                customerCode: state is NewOrderPhoneLookupSuccess
                    ? state.customerCode
                    : '',
                lookupSuggestion: buildLookupSuggestion(
                  state,
                  pendingCodeLookup: _uiSession.pendingCodeLookup,
                ),
                isLookupLoading: state is NewOrderPhoneLookupLoading,
                onPhoneChanged: _onPhoneChanged,
                onSavePressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<NewOrderCubit>().saveOrder(
                      phone: _phoneController.text,
                      name: _nameController.text,
                      address: _addressController.text,
                      notes: _notesController.text,
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
