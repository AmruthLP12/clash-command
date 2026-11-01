import 'package:flutter/material.dart';

/// Village realm distinction between Home Village and Builder Base.
enum VillageRealm {
  homeVillage('Home Village', Icons.fort_outlined),
  builderBase('Builder Base', Icons.nightlight_round_outlined);

  const VillageRealm(this.label, this.icon);
  final String label;
  final IconData icon;

  bool get isHomeVillage => this == VillageRealm.homeVillage;
  bool get isBuilderBase => this == VillageRealm.builderBase;
}
