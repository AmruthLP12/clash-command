// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_upgrade_suggestions_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomUpgradeSuggestionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CustomUpgradeSuggestionsTable get customUpgradeSuggestions =>
      attachedDatabase.customUpgradeSuggestions;
  CustomUpgradeSuggestionsDaoManager get managers =>
      CustomUpgradeSuggestionsDaoManager(this);
}

class CustomUpgradeSuggestionsDaoManager {
  final _$CustomUpgradeSuggestionsDaoMixin _db;
  CustomUpgradeSuggestionsDaoManager(this._db);
  $$CustomUpgradeSuggestionsTableTableManager get customUpgradeSuggestions =>
      $$CustomUpgradeSuggestionsTableTableManager(
        _db.attachedDatabase,
        _db.customUpgradeSuggestions,
      );
}
