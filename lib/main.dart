import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const appName = 'ROMAN HENRI CHARLES';
const developerName = 'ROMAN HENRI CHARLES';
const supportEmail = 'support@romanhenricharles.com';
const screenshotMode = bool.fromEnvironment('SCREENSHOT_MODE');

const brandPrimary = Color(0xFF2F4560);
const brandDeep = Color(0xFF1F314E);
const brandAmber = Color(0xFFC9892B);
const brandGreen = Color(0xFF2F7D66);
const brandSurface = Color(0xFFF6F4ED);

void main() {
  runApp(const OperationsApp());
}

class OperationsApp extends StatefulWidget {
  const OperationsApp({super.key});

  @override
  State<OperationsApp> createState() => _OperationsAppState();
}

class _OperationsAppState extends State<OperationsApp> {
  late final OperationsStore store;

  @override
  void initState() {
    super.initState();
    store = OperationsStore()..load();
  }

  @override
  void dispose() {
    store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: brandPrimary,
          brightness: Brightness.light,
        ).copyWith(
          primary: brandPrimary,
          onPrimary: Colors.white,
          secondary: brandAmber,
          onSecondary: const Color(0xFF1F1608),
          tertiary: brandGreen,
          surface: const Color(0xFFFFFCF6),
          surfaceContainerHighest: const Color(0xFFE7E2D8),
        );

    return AnimatedBuilder(
      animation: store,
      builder: (context, _) {
        return MaterialApp(
          title: appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: scheme,
            scaffoldBackgroundColor: brandSurface,
            cardTheme: CardThemeData(
              elevation: 0,
              color: scheme.surface,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: scheme.outlineVariant),
              ),
            ),
            appBarTheme: const AppBarTheme(
              centerTitle: false,
              backgroundColor: brandSurface,
              foregroundColor: brandDeep,
              elevation: 0,
            ),
            filledButtonTheme: FilledButtonThemeData(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          home: store.isLoaded
              ? OperationsShell(store: store)
              : const LoadingScreen(),
        );
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

enum WorkType {
  compliance,
  maintenance,
  payroll;

  String get label => switch (this) {
    WorkType.compliance => 'Compliance',
    WorkType.maintenance => 'Maintenance',
    WorkType.payroll => 'Payroll',
  };

  IconData get icon => switch (this) {
    WorkType.compliance => Icons.verified_user_outlined,
    WorkType.maintenance => Icons.handyman_outlined,
    WorkType.payroll => Icons.payments_outlined,
  };

  Color get color => switch (this) {
    WorkType.compliance => brandPrimary,
    WorkType.maintenance => brandGreen,
    WorkType.payroll => brandAmber,
  };
}

enum WorkStatus {
  open,
  inProgress,
  ready,
  resolved;

  String get label => switch (this) {
    WorkStatus.open => 'Open',
    WorkStatus.inProgress => 'In progress',
    WorkStatus.ready => 'Ready',
    WorkStatus.resolved => 'Resolved',
  };
}

class InventoryItem {
  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.reorderPoint,
    required this.location,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String category;
  final int quantity;
  final int reorderPoint;
  final String location;
  final DateTime updatedAt;

  bool get needsRestock => quantity <= reorderPoint;

  String get statusLabel {
    if (needsRestock) {
      return 'Restock';
    }
    if (quantity <= reorderPoint + 5) {
      return 'Watch';
    }
    return 'Ready';
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'quantity': quantity,
    'reorderPoint': reorderPoint,
    'location': location,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory InventoryItem.fromJson(Map<String, Object?> json) {
    return InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      reorderPoint: json['reorderPoint'] as int,
      location: json['location'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class WorkRecord {
  const WorkRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.owner,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final WorkType type;
  final String title;
  final String owner;
  final WorkStatus status;
  final String priority;
  final DateTime dueDate;
  final String notes;
  final DateTime createdAt;

  bool get isOpen => status != WorkStatus.resolved;

  WorkRecord copyWith({WorkStatus? status}) {
    return WorkRecord(
      id: id,
      type: type,
      title: title,
      owner: owner,
      status: status ?? this.status,
      priority: priority,
      dueDate: dueDate,
      notes: notes,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'type': type.name,
    'title': title,
    'owner': owner,
    'status': status.name,
    'priority': priority,
    'dueDate': dueDate.toIso8601String(),
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory WorkRecord.fromJson(Map<String, Object?> json) {
    return WorkRecord(
      id: json['id'] as String,
      type: WorkType.values.byName(json['type'] as String),
      title: json['title'] as String,
      owner: json['owner'] as String,
      status: WorkStatus.values.byName(json['status'] as String),
      priority: json['priority'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      notes: json['notes'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class OperationsStore extends ChangeNotifier {
  static const _inventoryKey = 'rhc_inventory_v1';
  static const _workKey = 'rhc_work_v1';

  bool isLoaded = false;
  List<InventoryItem> inventory = const [];
  List<WorkRecord> work = const [];

  int get restockCount => inventory.where((item) => item.needsRestock).length;
  int get openWorkCount => work.where((record) => record.isOpen).length;

  int get readyReportCount {
    return work.where((record) => record.status == WorkStatus.ready).length;
  }

  int get payrollQueue {
    return work
        .where((record) => record.type == WorkType.payroll && record.isOpen)
        .length;
  }

  Future<void> load() async {
    if (screenshotMode) {
      inventory = _starterInventory();
      work = _starterWork();
      isLoaded = true;
      notifyListeners();
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    inventory = _decodeInventory(preferences.getString(_inventoryKey));
    work = _decodeWork(preferences.getString(_workKey));
    if (inventory.isEmpty && work.isEmpty) {
      inventory = _starterInventory();
      work = _starterWork();
    }
    isLoaded = true;
    notifyListeners();
  }

  Future<void> addInventory(InventoryItem item) async {
    inventory = [item, ...inventory];
    notifyListeners();
    await _saveInventory();
  }

  Future<void> addWork(WorkRecord record) async {
    work = [record, ...work];
    notifyListeners();
    await _saveWork();
  }

  Future<void> updateWorkStatus(String id, WorkStatus status) async {
    work = [
      for (final record in work)
        if (record.id == id) record.copyWith(status: status) else record,
    ];
    notifyListeners();
    await _saveWork();
  }

  Future<void> resetLocalData() async {
    inventory = _starterInventory();
    work = _starterWork();
    notifyListeners();
    if (screenshotMode) {
      return;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_inventoryKey);
    await preferences.remove(_workKey);
  }

  List<InventoryItem> _decodeInventory(String? payload) {
    if (payload == null || payload.isEmpty) {
      return [];
    }
    final raw = jsonDecode(payload) as List<dynamic>;
    return raw
        .map(
          (item) =>
              InventoryItem.fromJson(Map<String, Object?>.from(item as Map)),
        )
        .toList();
  }

  List<WorkRecord> _decodeWork(String? payload) {
    if (payload == null || payload.isEmpty) {
      return [];
    }
    final raw = jsonDecode(payload) as List<dynamic>;
    return raw
        .map(
          (item) => WorkRecord.fromJson(Map<String, Object?>.from(item as Map)),
        )
        .toList();
  }

  Future<void> _saveInventory() async {
    if (screenshotMode) {
      return;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _inventoryKey,
      jsonEncode(inventory.map((item) => item.toJson()).toList()),
    );
  }

  Future<void> _saveWork() async {
    if (screenshotMode) {
      return;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _workKey,
      jsonEncode(work.map((record) => record.toJson()).toList()),
    );
  }
}

List<InventoryItem> _starterInventory() {
  final now = DateTime.now();
  return [
    InventoryItem(
      id: 'inv-001',
      name: 'Safety labels',
      category: 'Compliance',
      quantity: 18,
      reorderPoint: 12,
      location: 'Main stockroom',
      updatedAt: now.subtract(const Duration(hours: 4)),
    ),
    InventoryItem(
      id: 'inv-002',
      name: 'Filter cartridges',
      category: 'Maintenance',
      quantity: 7,
      reorderPoint: 8,
      location: 'Workshop shelf B',
      updatedAt: now.subtract(const Duration(days: 1)),
    ),
    InventoryItem(
      id: 'inv-003',
      name: 'Payroll envelopes',
      category: 'Payroll',
      quantity: 42,
      reorderPoint: 20,
      location: 'Office cabinet',
      updatedAt: now.subtract(const Duration(days: 2)),
    ),
    InventoryItem(
      id: 'inv-004',
      name: 'Inspection binders',
      category: 'Compliance',
      quantity: 5,
      reorderPoint: 5,
      location: 'Records desk',
      updatedAt: now.subtract(const Duration(hours: 9)),
    ),
  ];
}

List<WorkRecord> _starterWork() {
  final now = DateTime.now();
  return [
    WorkRecord(
      id: 'wrk-001',
      type: WorkType.compliance,
      title: 'Monthly safety register',
      owner: 'Operations lead',
      status: WorkStatus.ready,
      priority: 'High',
      dueDate: now.add(const Duration(days: 1)),
      notes: 'Inventory counts and incident checks are ready for review.',
      createdAt: now.subtract(const Duration(days: 2)),
    ),
    WorkRecord(
      id: 'wrk-002',
      type: WorkType.maintenance,
      title: 'Service loading bay lift',
      owner: 'Maintenance desk',
      status: WorkStatus.inProgress,
      priority: 'High',
      dueDate: now.add(const Duration(days: 2)),
      notes: 'Parts are available. Confirm technician window.',
      createdAt: now.subtract(const Duration(days: 3)),
    ),
    WorkRecord(
      id: 'wrk-003',
      type: WorkType.payroll,
      title: 'Prepare weekly hours summary',
      owner: 'Payroll coordinator',
      status: WorkStatus.open,
      priority: 'Normal',
      dueDate: now.add(const Duration(days: 4)),
      notes: 'Check overtime flags before payroll approval.',
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    WorkRecord(
      id: 'wrk-004',
      type: WorkType.compliance,
      title: 'Supplier certificate review',
      owner: 'Admin team',
      status: WorkStatus.open,
      priority: 'Normal',
      dueDate: now.add(const Duration(days: 6)),
      notes: 'Two certificates need expiry date confirmation.',
      createdAt: now.subtract(const Duration(hours: 12)),
    ),
  ];
}

class OperationsShell extends StatefulWidget {
  const OperationsShell({required this.store, super.key});

  final OperationsStore store;

  @override
  State<OperationsShell> createState() => _OperationsShellState();
}

class _OperationsShellState extends State<OperationsShell> {
  int selectedIndex = 0;

  Future<void> _openInventoryForm() async {
    final item = await Navigator.of(context).push<InventoryItem>(
      MaterialPageRoute(builder: (_) => const InventoryFormScreen()),
    );
    if (!mounted || item == null) {
      return;
    }
    await widget.store.addInventory(item);
  }

  Future<void> _openWorkForm({
    WorkType initialType = WorkType.maintenance,
  }) async {
    final record = await Navigator.of(context).push<WorkRecord>(
      MaterialPageRoute(
        builder: (_) => WorkFormScreen(initialType: initialType),
      ),
    );
    if (!mounted || record == null) {
      return;
    }
    await widget.store.addWork(record);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        store: widget.store,
        onAddInventory: _openInventoryForm,
        onAddWork: (type) => _openWorkForm(initialType: type),
        onViewWork: (record) => _openWorkDetail(record),
      ),
      InventoryScreen(items: widget.store.inventory, onAdd: _openInventoryForm),
      WorkScreen(
        records: widget.store.work,
        onAdd: (type) => _openWorkForm(initialType: type),
        onOpenRecord: _openWorkDetail,
      ),
      ReportsScreen(store: widget.store),
      SettingsScreen(store: widget.store),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedIndex == 0 ? appName : _titleFor(selectedIndex)),
      ),
      body: SafeArea(child: screens[selectedIndex]),
      floatingActionButton: _fabForSelectedTab(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment),
            label: 'Work',
          ),
          NavigationDestination(
            icon: Icon(Icons.summarize_outlined),
            selectedIcon: Icon(Icons.summarize),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget? _fabForSelectedTab() {
    if (selectedIndex == 1) {
      return FloatingActionButton.extended(
        heroTag: 'add_inventory',
        tooltip: 'Add inventory item',
        onPressed: _openInventoryForm,
        icon: const Icon(Icons.add),
        label: const Text('Item'),
      );
    }
    if (selectedIndex == 2) {
      return FloatingActionButton.extended(
        heroTag: 'add_work',
        tooltip: 'Add work record',
        onPressed: () => _openWorkForm(),
        icon: const Icon(Icons.add_task),
        label: const Text('Record'),
      );
    }
    return null;
  }

  Future<void> _openWorkDetail(WorkRecord record) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => WorkDetailScreen(
          record: record,
          onStatusChanged: widget.store.updateWorkStatus,
        ),
      ),
    );
  }

  String _titleFor(int index) {
    return switch (index) {
      1 => 'Inventory',
      2 => 'Work',
      3 => 'Reports',
      4 => 'Settings',
      _ => appName,
    };
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.store,
    required this.onAddInventory,
    required this.onAddWork,
    required this.onViewWork,
    super.key,
  });

  final OperationsStore store;
  final VoidCallback onAddInventory;
  final ValueChanged<WorkType> onAddWork;
  final ValueChanged<WorkRecord> onViewWork;

  @override
  Widget build(BuildContext context) {
    final urgentRecords = store.work.where((record) => record.isOpen).take(3);

    return AppScrollView(
      children: [
        const HeaderPanel(),
        MetricGrid(
          metrics: [
            MetricData(
              'Inventory lines',
              '${store.inventory.length}',
              Icons.inventory_2_outlined,
            ),
            MetricData(
              'Restock watch',
              '${store.restockCount}',
              Icons.warning_amber_outlined,
            ),
            MetricData(
              'Open work',
              '${store.openWorkCount}',
              Icons.assignment_late_outlined,
            ),
            MetricData(
              'Reports ready',
              '${store.readyReportCount}',
              Icons.check_circle_outline,
            ),
          ],
        ),
        SectionHeader(
          title: 'Quick capture',
          trailing: Text(
            'Local records',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onAddInventory,
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('Inventory'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => onAddWork(WorkType.maintenance),
                icon: const Icon(Icons.add_task),
                label: const Text('Work'),
              ),
            ),
          ],
        ),
        const SectionHeader(title: 'Priority board'),
        ...urgentRecords.map(
          (record) =>
              WorkRecordTile(record: record, onTap: () => onViewWork(record)),
        ),
      ],
    );
  }
}

class HeaderPanel extends StatelessWidget {
  const HeaderPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: brandDeep,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'docs/featured.png',
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.42),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset('docs/icon.png', width: 48, height: 48),
                const SizedBox(height: 18),
                Text(
                  'Daily operations command',
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Track inventory, maintenance, compliance, and payroll tasks in one local workspace.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({required this.items, required this.onAdd, super.key});

  final List<InventoryItem> items;
  final VoidCallback onAdd;

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where(
          (item) =>
              item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.category.toLowerCase().contains(query.toLowerCase()) ||
              item.location.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();

    return AppScrollView(
      children: [
        TextField(
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            labelText: 'Search inventory',
          ),
          onChanged: (value) => setState(() => query = value),
        ),
        const SizedBox(height: 12),
        SectionHeader(
          title: 'Stock lines',
          trailing: Text('${filtered.length} shown'),
        ),
        if (filtered.isEmpty)
          EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No matching stock',
            actionLabel: 'Add item',
            onAction: widget.onAdd,
          )
        else
          ...filtered.map(
            (item) => InventoryTile(
              item: item,
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => InventoryDetailScreen(item: item),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class WorkScreen extends StatefulWidget {
  const WorkScreen({
    required this.records,
    required this.onAdd,
    required this.onOpenRecord,
    super.key,
  });

  final List<WorkRecord> records;
  final ValueChanged<WorkType> onAdd;
  final ValueChanged<WorkRecord> onOpenRecord;

  @override
  State<WorkScreen> createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {
  WorkType? filter;

  @override
  Widget build(BuildContext context) {
    final visible = widget.records
        .where((record) => filter == null || record.type == filter)
        .toList();

    return AppScrollView(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: const Text('All'),
              selected: filter == null,
              onSelected: (_) => setState(() => filter = null),
            ),
            for (final type in WorkType.values)
              FilterChip(
                avatar: Icon(type.icon, size: 18),
                label: Text(type.label),
                selected: filter == type,
                onSelected: (_) => setState(() => filter = type),
              ),
          ],
        ),
        SectionHeader(
          title: 'Work queue',
          trailing: Text('${visible.length} records'),
        ),
        if (visible.isEmpty)
          EmptyState(
            icon: Icons.assignment_outlined,
            title: 'No records yet',
            actionLabel: 'Add record',
            onAction: () => widget.onAdd(filter ?? WorkType.maintenance),
          )
        else
          ...visible.map(
            (record) => WorkRecordTile(
              record: record,
              onTap: () => widget.onOpenRecord(record),
            ),
          ),
      ],
    );
  }
}

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({required this.store, super.key});

  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    final totalQuantity = store.inventory.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final complianceOpen = store.work
        .where((record) => record.type == WorkType.compliance && record.isOpen)
        .length;
    final maintenanceOpen = store.work
        .where((record) => record.type == WorkType.maintenance && record.isOpen)
        .length;

    return AppScrollView(
      children: [
        const SectionHeader(title: 'Operational summaries'),
        ReportPanel(
          icon: Icons.verified_user_outlined,
          title: 'Compliance reporting',
          value: '$complianceOpen open checks',
          description:
              'Certificate, safety register, and audit follow-ups are grouped for review.',
        ),
        ReportPanel(
          icon: Icons.handyman_outlined,
          title: 'Maintenance requests',
          value: '$maintenanceOpen active requests',
          description:
              'Equipment issues stay visible until they are marked ready or resolved.',
        ),
        ReportPanel(
          icon: Icons.payments_outlined,
          title: 'Payroll preparation',
          value: '${store.payrollQueue} payroll items',
          description:
              'Payroll work records keep hours summaries and approval notes together.',
        ),
        ReportPanel(
          icon: Icons.inventory_2_outlined,
          title: 'Inventory position',
          value: '$totalQuantity units tracked',
          description:
              '${store.restockCount} stock lines are at or below their reorder point.',
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.store, super.key});

  final OperationsStore store;

  @override
  Widget build(BuildContext context) {
    return AppScrollView(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Image.asset('docs/icon.png', width: 44, height: 44),
          title: const Text(appName),
          subtitle: const Text('Local operations workspace'),
        ),
        const Divider(),
        const InfoTile(
          icon: Icons.lock_outline,
          title: 'Local storage',
          body:
              'Inventory records, work requests, report notes, and preferences stay on this device.',
        ),
        const InfoTile(
          icon: Icons.cloud_off_outlined,
          title: 'No account or cloud sync',
          body:
              'The app does not upload operational records, create accounts, or connect to external services.',
        ),
        const InfoTile(
          icon: Icons.privacy_tip_outlined,
          title: 'Privacy contact',
          body: '$developerName\n$supportEmail',
        ),
        FilledButton.tonalIcon(
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Reset local records'),
                content: const Text(
                  'This restores the starter records saved on this device.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: const Text('Reset'),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await store.resetLocalData();
            }
          },
          icon: const Icon(Icons.restart_alt),
          label: const Text('Reset local records'),
        ),
      ],
    );
  }
}

class InventoryFormScreen extends StatefulWidget {
  const InventoryFormScreen({super.key});

  @override
  State<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends State<InventoryFormScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final quantityController = TextEditingController(text: '1');
  final reorderController = TextEditingController(text: '5');
  final locationController = TextEditingController(text: 'Main stockroom');
  String category = 'Maintenance';

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    reorderController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New inventory item')),
      body: Form(
        key: formKey,
        child: AppScrollView(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Item name'),
              textInputAction: TextInputAction.next,
              validator: _required,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                DropdownMenuItem(
                  value: 'Compliance',
                  child: Text('Compliance'),
                ),
                DropdownMenuItem(
                  value: 'Maintenance',
                  child: Text('Maintenance'),
                ),
                DropdownMenuItem(value: 'Payroll', child: Text('Payroll')),
                DropdownMenuItem(value: 'General', child: Text('General')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    validator: _positiveInt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: reorderController,
                    decoration: const InputDecoration(labelText: 'Reorder at'),
                    keyboardType: TextInputType.number,
                    validator: _positiveInt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(labelText: 'Storage location'),
              validator: _required,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save item'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      InventoryItem(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        category: category,
        quantity: int.parse(quantityController.text.trim()),
        reorderPoint: int.parse(reorderController.text.trim()),
        location: locationController.text.trim(),
        updatedAt: DateTime.now(),
      ),
    );
  }
}

class WorkFormScreen extends StatefulWidget {
  const WorkFormScreen({required this.initialType, super.key});

  final WorkType initialType;

  @override
  State<WorkFormScreen> createState() => _WorkFormScreenState();
}

class _WorkFormScreenState extends State<WorkFormScreen> {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final ownerController = TextEditingController(text: 'Operations lead');
  final notesController = TextEditingController();
  late WorkType type;
  WorkStatus status = WorkStatus.open;
  String priority = 'Normal';
  int dueInDays = 3;

  @override
  void initState() {
    super.initState();
    type = widget.initialType;
  }

  @override
  void dispose() {
    titleController.dispose();
    ownerController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New work record')),
      body: Form(
        key: formKey,
        child: AppScrollView(
          children: [
            DropdownButtonFormField<WorkType>(
              initialValue: type,
              decoration: const InputDecoration(labelText: 'Record type'),
              items: WorkType.values
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.label),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => type = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: ownerController,
              decoration: const InputDecoration(labelText: 'Owner'),
              validator: _required,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<WorkStatus>(
                    initialValue: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: WorkStatus.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => status = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: priority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: const [
                      DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                      DropdownMenuItem(value: 'High', child: Text('High')),
                      DropdownMenuItem(
                        value: 'Critical',
                        child: Text('Critical'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => priority = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: dueInDays,
              decoration: const InputDecoration(labelText: 'Due window'),
              items: const [
                DropdownMenuItem(value: 1, child: Text('Tomorrow')),
                DropdownMenuItem(value: 3, child: Text('Next 3 days')),
                DropdownMenuItem(value: 7, child: Text('Next week')),
                DropdownMenuItem(value: 14, child: Text('Next 2 weeks')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => dueInDays = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save record'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!formKey.currentState!.validate()) {
      return;
    }
    Navigator.of(context).pop(
      WorkRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        type: type,
        title: titleController.text.trim(),
        owner: ownerController.text.trim(),
        status: status,
        priority: priority,
        dueDate: DateTime.now().add(Duration(days: dueInDays)),
        notes: notesController.text.trim().isEmpty
            ? 'No additional notes.'
            : notesController.text.trim(),
        createdAt: DateTime.now(),
      ),
    );
  }
}

class WorkDetailScreen extends StatelessWidget {
  const WorkDetailScreen({
    required this.record,
    required this.onStatusChanged,
    super.key,
  });

  final WorkRecord record;
  final Future<void> Function(String id, WorkStatus status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(record.type.label)),
      body: AppScrollView(
        children: [
          IconBadge(icon: record.type.icon, color: record.type.color),
          const SizedBox(height: 16),
          Text(
            record.title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '${record.priority} priority • Due ${formatDate(record.dueDate)}',
          ),
          const SizedBox(height: 16),
          StatusStrip(label: record.status.label, color: record.type.color),
          const SizedBox(height: 16),
          DetailRow(label: 'Owner', value: record.owner),
          DetailRow(label: 'Created', value: formatDate(record.createdAt)),
          DetailRow(label: 'Notes', value: record.notes),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: record.status == WorkStatus.resolved
                ? null
                : () async {
                    await onStatusChanged(record.id, WorkStatus.resolved);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Mark resolved'),
          ),
        ],
      ),
    );
  }
}

class InventoryDetailScreen extends StatelessWidget {
  const InventoryDetailScreen({required this.item, super.key});

  final InventoryItem item;

  @override
  Widget build(BuildContext context) {
    final statusColor = item.needsRestock ? Colors.red.shade700 : brandGreen;
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory detail')),
      body: AppScrollView(
        children: [
          IconBadge(icon: Icons.inventory_2_outlined, color: statusColor),
          const SizedBox(height: 16),
          Text(
            item.name,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          StatusStrip(label: item.statusLabel, color: statusColor),
          const SizedBox(height: 16),
          DetailRow(label: 'Category', value: item.category),
          DetailRow(label: 'Quantity', value: '${item.quantity} units'),
          DetailRow(
            label: 'Reorder point',
            value: '${item.reorderPoint} units',
          ),
          DetailRow(label: 'Location', value: item.location),
          DetailRow(label: 'Updated', value: formatDate(item.updatedAt)),
        ],
      ),
    );
  }
}

class MetricGrid extends StatelessWidget {
  const MetricGrid({required this.metrics, super.key});

  final List<MetricData> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 680 ? 4 : 2;
        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: count == 4 ? 1.25 : 0.88,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [for (final metric in metrics) MetricCard(metric: metric)],
        );
      },
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({required this.metric, super.key});

  final MetricData metric;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(metric.icon, color: brandPrimary, size: 22),
            const SizedBox(height: 8),
            Text(
              metric.value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              metric.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class MetricData {
  const MetricData(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class InventoryTile extends StatelessWidget {
  const InventoryTile({required this.item, required this.onTap, super.key});

  final InventoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = item.needsRestock ? Colors.red.shade700 : brandGreen;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: IconBadge(
          icon: Icons.inventory_2_outlined,
          color: statusColor,
        ),
        title: Text(item.name),
        subtitle: Text('${item.category} • ${item.location}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.quantity}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(item.statusLabel),
          ],
        ),
      ),
    );
  }
}

class WorkRecordTile extends StatelessWidget {
  const WorkRecordTile({required this.record, required this.onTap, super.key});

  final WorkRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: IconBadge(icon: record.type.icon, color: record.type.color),
        title: Text(record.title),
        subtitle: Text('${record.owner} • Due ${formatDate(record.dueDate)}'),
        trailing: StatusPill(
          label: record.status.label,
          color: record.type.color,
        ),
      ),
    );
  }
}

class ReportPanel extends StatelessWidget {
  const ReportPanel({
    required this.icon,
    required this.title,
    required this.value,
    required this.description,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconBadge(icon: icon, color: brandPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: brandPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(description),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  const InfoTile({
    required this.icon,
    required this.title,
    required this.body,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: IconBadge(icon: icon, color: brandPrimary),
      title: Text(title),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(body),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final trailingWidget = trailing;
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: brandDeep,
              ),
            ),
          ),
          ?trailingWidget,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 36, color: brandPrimary),
            const SizedBox(height: 10),
            Text(title),
            const SizedBox(height: 12),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  const IconBadge({required this.icon, required this.color, super.key});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class StatusStrip extends StatelessWidget {
  const StatusStrip({required this.label, required this.color, super.key});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: brandPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(value),
        ],
      ),
    );
  }
}

class AppScrollView extends StatelessWidget {
  const AppScrollView({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: children,
    );
  }
}

String? _required(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Required';
  }
  return null;
}

String? _positiveInt(String? value) {
  final parsed = int.tryParse(value ?? '');
  if (parsed == null || parsed < 0) {
    return 'Use a whole number';
  }
  return null;
}

String formatDate(DateTime value) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}
