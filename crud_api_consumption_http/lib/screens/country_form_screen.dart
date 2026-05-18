import 'package:crud_api_consumption_http/models/country.dart';
import 'package:crud_api_consumption_http/providers/country_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum FormMode { create, update }

class CountryFormScreen extends StatefulWidget {
  final FormMode mode;
  final Country? existingCountry;

  const CountryFormScreen({
    super.key,
    required this.mode,
    this.existingCountry,
  });

  @override
  State<CountryFormScreen> createState() => _CountryFormScreenState();
}

class _CountryFormScreenState extends State<CountryFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _commonName;
  late final TextEditingController _officialName;
  late final TextEditingController _nativeLangCode;
  late final TextEditingController _nativeOfficial;
  late final TextEditingController _nativeCommon;
  late final TextEditingController _currencyCode;
  late final TextEditingController _currencyName;
  late final TextEditingController _currencySymbol;
  late final TextEditingController _capital;

  @override
  void initState() {
    super.initState();
    final c = widget.existingCountry;

    _commonName = TextEditingController(text: c?.name.common ?? '');
    _officialName = TextEditingController(text: c?.name.official ?? '');

    final firstNative = c?.name.nativeName.entries.firstOrNull;
    _nativeLangCode = TextEditingController(text: firstNative?.key ?? '');
    _nativeOfficial =
        TextEditingController(text: firstNative?.value.official ?? '');
    _nativeCommon =
        TextEditingController(text: firstNative?.value.common ?? '');

    final firstCurrency = c?.currency.entries.firstOrNull;
    _currencyCode = TextEditingController(text: firstCurrency?.key ?? '');
    _currencyName =
        TextEditingController(text: firstCurrency?.value.name ?? '');
    _currencySymbol =
        TextEditingController(text: firstCurrency?.value.symbol ?? '');

    _capital = TextEditingController(
      text: (c?.capitals.isNotEmpty ?? false) ? c!.capitals.first : '',
    );
  }

  @override
  void dispose() {
    for (final ctrl in [
      _commonName, _officialName, _nativeLangCode,
      _nativeOfficial, _nativeCommon, _currencyCode,
      _currencyName, _currencySymbol, _capital,
    ]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CountryProvider>();
    final isCreate = widget.mode == FormMode.create;

    Country? result;

    if (isCreate) {
      result = await provider.createCountry(
        commonName: _commonName.text.trim(),
        officialName: _officialName.text.trim(),
        nativeLangCode: _nativeLangCode.text.trim(),
        nativeOfficial: _nativeOfficial.text.trim(),
        nativeCommon: _nativeCommon.text.trim(),
        currencyCode: _currencyCode.text.trim(),
        currencyName: _currencyName.text.trim(),
        currencySymbol: _currencySymbol.text.trim(),
        capital: _capital.text.trim(),
      );
    } else {
      result = await provider.updateCountry(
        oldCommonName: widget.existingCountry!.name.common,
        commonName: _commonName.text.trim(),
        officialName: _officialName.text.trim(),
        nativeLangCode: _nativeLangCode.text.trim(),
        nativeOfficial: _nativeOfficial.text.trim(),
        nativeCommon: _nativeCommon.text.trim(),
        currencyCode: _currencyCode.text.trim(),
        currencyName: _currencyName.text.trim(),
        currencySymbol: _currencySymbol.text.trim(),
        capital: _capital.text.trim(),
      );
    }

    if (!mounted) return;

    if (result != null) {
      Navigator.pop(context, result);
    } else {
      final err = provider.errorMessage;
      if (err != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(err),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        provider.clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreate = widget.mode == FormMode.create;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Text(
          isCreate ? 'Add New Country' : 'Edit Country Info',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<CountryProvider>(
        builder: (context, provider, _) {
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionCard(
                        title: 'Primary Names',
                        icon: Icons.public,
                        children: [
                          _field(
                            ctrl: _commonName,
                            label: 'Common Name',
                            hint: 'e.g. Canada',
                            required: true,
                          ),
                          _field(
                            ctrl: _officialName,
                            label: 'Official Name',
                            hint: 'e.g. Dominion of Canada',
                            required: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'Native Identity',
                        icon: Icons.translate_rounded,
                        children: [
                          _field(
                            ctrl: _nativeLangCode,
                            label: 'Language ISO Code',
                            hint: 'e.g. eng, fra',
                          ),
                          _field(
                            ctrl: _nativeOfficial,
                            label: 'Native Official Name',
                            hint: 'e.g. Dominion of Canada',
                          ),
                          _field(
                            ctrl: _nativeCommon,
                            label: 'Native Common Name',
                            hint: 'e.g. Canada',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'Finance & Currencies',
                        icon: Icons.payments_outlined,
                        children: [
                          _field(
                            ctrl: _currencyCode,
                            label: 'Currency Code',
                            hint: 'e.g. CAD',
                          ),
                          _field(
                            ctrl: _currencyName,
                            label: 'Currency Name',
                            hint: 'e.g. Canadian dollar',
                          ),
                          _field(
                            ctrl: _currencySymbol,
                            label: 'Currency Symbol',
                            hint: 'e.g. \$',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: 'Administrative Capital',
                        icon: Icons.business_outlined,
                        children: [
                          _field(
                            ctrl: _capital,
                            label: 'Capital City',
                            hint: 'e.g. Ottawa',
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: provider.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F2537),
                          foregroundColor: Colors.white,
                          elevation: 1,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                isCreate ? 'Register Country' : 'Save Modifications',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              if (provider.isLoading)
                Container(
                  color: const Color(0x33000000),
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0F2537)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0x05000000),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: const Color(0x140F2537),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: const Color(0xFF0F2537)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    String? hint,
    bool required = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          floatingLabelStyle: const TextStyle(color: Color(0xFF0F2537), fontWeight: FontWeight.bold),
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0F2537), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
      ),
    );
  }
}
