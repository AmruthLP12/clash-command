import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/domain/models/upgrade_category.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/features/upgrades/application/upgrades_notifier.dart';

/// Bottom sheet for adding a new upgrade to a village.
class AddUpgradeSheet extends ConsumerStatefulWidget {
  const AddUpgradeSheet({super.key, required this.village});

  final Village village;

  @override
  ConsumerState<AddUpgradeSheet> createState() => _AddUpgradeSheetState();
}

class _AddUpgradeSheetState extends ConsumerState<AddUpgradeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _daysController = TextEditingController(text: '0');
  final _hoursController = TextEditingController(text: '0');
  final _minutesController = TextEditingController(text: '0');
  final _slotController = TextEditingController();
  UpgradeCategory _category = UpgradeCategory.building;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _daysController.dispose();
    _hoursController.dispose();
    _minutesController.dispose();
    _slotController.dispose();
    super.dispose();
  }

  Duration get _duration {
    final days = int.tryParse(_daysController.text) ?? 0;
    final hours = int.tryParse(_hoursController.text) ?? 0;
    final minutes = int.tryParse(_minutesController.text) ?? 0;
    return Duration(days: days, hours: hours, minutes: minutes);
  }

  bool get _durationValid => _duration > Duration.zero;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_durationValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Duration must be greater than zero.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(upgradesNotifierProvider.notifier).startUpgrade(
            villageId: widget.village.id,
            name: _nameController.text.trim(),
            category: _category,
            duration: _duration,
            slotKey: _slotController.text.trim().isEmpty
                ? null
                : _slotController.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Track upgrade — ${widget.village.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Upgrade name *',
                  hintText: 'e.g. Barracks, Archer Queen',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),

              // Category picker
              DropdownButtonFormField<UpgradeCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                dropdownColor: AppColors.surfaceVariant,
                items: UpgradeCategory.values
                    .map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c.displayName),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 12),

              // Duration row
              const Text(
                'Duration *',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: _DurationField(
                      controller: _daysController,
                      label: 'Days',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DurationField(
                      controller: _hoursController,
                      label: 'Hours',
                      max: 23,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _DurationField(
                      controller: _minutesController,
                      label: 'Min',
                      max: 59,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Optional slot
              TextFormField(
                controller: _slotController,
                decoration: const InputDecoration(
                  labelText: 'Builder/slot (optional)',
                  hintText: 'e.g. Builder 1',
                ),
              ),
              const SizedBox(height: 20),

              // Submit
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text('Start tracking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationField extends StatelessWidget {
  const _DurationField({
    required this.controller,
    required this.label,
    this.max,
  });

  final TextEditingController controller;
  final String label;
  final int? max;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      validator: (v) {
        final n = int.tryParse(v ?? '');
        if (n == null || n < 0) return '≥ 0';
        if (max != null && n > max!) return '≤ $max';
        return null;
      },
    );
  }
}
