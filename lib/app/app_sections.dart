import 'package:flutter/material.dart';

import '../core/models/restaurant_models.dart';

class AppSection {
  const AppSection({
    required this.slug,
    required this.label,
    required this.icon,
    required this.roles,
    required this.summary,
  });

  final String slug;
  final String label;
  final IconData icon;
  final Set<UserRole> roles;
  final String summary;
}

const kAppSections = <AppSection>[
  AppSection(
    slug: 'dashboard',
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    roles: {UserRole.admin, UserRole.reception, UserRole.waiter, UserRole.kitchen},
    summary: 'Resumen del día, mesas y comandas.',
  ),
  AppSection(
    slug: 'recepcion',
    label: 'Caja Recepción',
    icon: Icons.point_of_sale_outlined,
    roles: {UserRole.admin, UserRole.reception},
    summary: 'Ingreso de grupos, paquetes y tiquetes.',
  ),
  AppSection(
    slug: 'reservas',
    label: 'Reservas',
    icon: Icons.event_available_outlined,
    roles: {UserRole.admin, UserRole.reception},
    summary: 'Agenda de reservas del restaurante.',
  ),
  AppSection(
    slug: 'eventos',
    label: 'Eventos / Colectivos',
    icon: Icons.groups_outlined,
    roles: {UserRole.admin, UserRole.reception},
    summary: 'Grupos, colectivos y pases de ingreso.',
  ),
  AppSection(
    slug: 'mesas',
    label: 'Zonas y Mesas',
    icon: Icons.table_restaurant_outlined,
    roles: {UserRole.admin, UserRole.waiter},
    summary: 'Mapa de mesas y ocupación.',
  ),
  AppSection(
    slug: 'comandas',
    label: 'Comandas',
    icon: Icons.restaurant_menu_outlined,
    roles: {UserRole.admin, UserRole.waiter},
    summary: 'Pedidos de mesas hacia cocina y barra.',
  ),
  AppSection(
    slug: 'produccion',
    label: 'Producción',
    icon: Icons.soup_kitchen_outlined,
    roles: {UserRole.admin, UserRole.kitchen},
    summary: 'Cola de cocina y estados de platos.',
  ),
  AppSection(
    slug: 'caja',
    label: 'Caja General',
    icon: Icons.receipt_long_outlined,
    roles: {UserRole.admin, UserRole.reception, UserRole.waiter},
    summary: 'Cierre de cuentas y cobros.',
  ),
  AppSection(
    slug: 'barra',
    label: 'Caja Barra',
    icon: Icons.local_bar_outlined,
    roles: {UserRole.admin, UserRole.kitchen},
    summary: 'Pedidos y caja de barra.',
  ),
  AppSection(
    slug: 'admin',
    label: 'Administración',
    icon: Icons.settings_outlined,
    roles: {UserRole.admin},
    summary: 'Catálogo, inventario y configuración.',
  ),
];
