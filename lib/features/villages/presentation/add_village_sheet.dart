import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:clash_command/app/theme/app_colors.dart';
import 'package:clash_command/domain/models/village.dart';
import 'package:clash_command/features/villages/application/villages_notifier.dart';

/// Bottom sheet for adding or editing a village.
class AddVillageSheet extends ConsumerStatefulWidget {
  const AddVillageSheet({super.key, this.village});

  final Village? village;

  bool get isEditing => village != null;

  @override
  ConsumerState<AddVillageSheet> createState() => _AddVillageSheetState();
}

class _AddVillageSheetState extends ConsumerState<AddVillageSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _notesController;
  late int _builderCapacity;
  late int? _townHallLevel;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.village?.name ?? '');
    _notesController = TextEditingController(text: widget.village?.notes ?? '');
    _builderCapacity = widget.village?.builderCapacity ?? 2;
    _townHallLevel = widget.village?.townHallLevel;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final name = _nameController.text.trim();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();

      if (widget.isEditing) {
        final updated = widget.village!.copyWith(
          name: name,
          townHallLevel: _townHallLevel,
          clearTownHallLevel: _townHallLevel == null,
          builderCapacity: _builderCapacity,
          notes: notes,
          clearNotes: notes == null,
        );
        await ref.read(villagesNotifierProvider.notifier).updateVillage(updated);
      } else {
        await ref.read(villagesNotifierProvider.notifier).createVillage(
              name: name,
              townHallLevel: _townHallLevel,
              builderCapacity: _builderCapacity,
              notes: notes,
            );
      }
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
                widget.isEditing ? 'Edit village' : 'Add village',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Village name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Village name *',
                  hintText: 'e.g. Main Village',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 12),

              // Town Hall level
              DropdownButtonFormField<int?>(
                initialValue: _townHallLevel,
                decoration: const InputDecoration(
                  labelText: 'Town Hall level (optional)',
                ),
                dropdownColor: AppColors.surfaceVariant,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Unknown')),
                  ...List.generate(
                    17,
                    (i) => DropdownMenuItem(
                      value: i + 1,
                      child: Text('TH ${i + 1}'),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _townHallLevel = v),
              ),
              const SizedBox(height: 12),

              // Builder capacity
              Row(
                children: [
                  const Text(
                    'Builder capacity',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: _builderCapacity > 1
                        ? () => setState(() => _builderCapacity--)
                        : null,
                  ),
                  Text(
                    '$_builderCapacity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _builderCapacity < 6
                        ? () => setState(() => _builderCapacity++)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'e.g. Focus on hero upgrades',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),

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
                      : Text(widget.isEditing ? 'Save changes' : 'Add village'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
