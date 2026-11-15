import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0F12),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FurnitureMeasureApp());
}

class FurnitureMeasureApp extends StatelessWidget {
  const FurnitureMeasureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wood & Glass Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0F12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFF59E0B), // Warm Teak/Amber
          secondary: Color(0xFF38BDF8), // Glass Cyan
          surface: Color(0xFF161A20),
        ),
      ),
      home: const MeasurementHomeScreen(),
    );
  }
}

class MeasurementRecord {
  final String title;
  final String detail;
  final double cft;
  final double sqft;
  final double amount;

  const MeasurementRecord({
    required this.title,
    required this.detail,
    required this.cft,
    required this.sqft,
    required this.amount,
  });
}

class MeasurementHomeScreen extends StatefulWidget {
  const MeasurementHomeScreen({super.key});

  @override
  State<MeasurementHomeScreen> createState() => _MeasurementHomeScreenState();
}

class _MeasurementHomeScreenState extends State<MeasurementHomeScreen> {
  int _currentTab = 0;
  final List<MeasurementRecord> _savedList = [];

  void _addRecord(MeasurementRecord record) {
    setState(() {
      _savedList.insert(0, record);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E242D),
        behavior: SnackBarBehavior.floating,
        content: Text(
          'Added: ${record.title}',
          style: const TextStyle(color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _removeRecord(int index) {
    setState(() => _savedList.removeAt(index));
  }

  void _clearAllRecords() {
    setState(() => _savedList.clear());
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      WoodCftTab(onSave: _addRecord),
      GlassCalcTab(onSave: _addRecord),
      SqftBoardTab(onSave: _addRecord),
      const UnitConverterTab(),
      EstimateListTab(
        records: _savedList,
        onDelete: _removeRecord,
        onClear: _clearAllRecords,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF12151A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.straighten_rounded,
                color: Color(0xFFF59E0B),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FURNITURE MEASURE PRO',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                Text(
                  'WOOD CFT • GLASS • SQFT • MM/IN',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white54,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (_savedList.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _currentTab = 4),
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_rounded,
                      size: 15,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${_savedList.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(
        index: _currentTab,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF12151A),
        indicatorColor: const Color(0xFFF59E0B).withOpacity(0.22),
        selectedIndex: _currentTab,
        onDestinationSelected: (i) => setState(() => _currentTab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forest_outlined),
            selectedIcon: Icon(Icons.forest_rounded, color: Color(0xFFF59E0B)),
            label: 'Wood CFT',
          ),
          NavigationDestination(
            icon: Icon(Icons.window_outlined),
            selectedIcon: Icon(Icons.window_rounded, color: Color(0xFF38BDF8)),
            label: 'Glass',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon:
                Icon(Icons.grid_view_rounded, color: Color(0xFFF59E0B)),
            label: 'SqFt/Board',
          ),
          NavigationDestination(
            icon: Icon(Icons.swap_horiz_rounded),
            selectedIcon:
                Icon(Icons.swap_horiz_rounded, color: Color(0xFF38BDF8)),
            label: 'mm ↔ in',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon:
                Icon(Icons.list_alt_rounded, color: Color(0xFFF59E0B)),
            label: 'Total List',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAB 1: WOOD CFT CALCULATOR (Sawn Timber + Round Log)
// ============================================================================
class WoodCftTab extends StatefulWidget {
  final void Function(MeasurementRecord) onSave;
  const WoodCftTab({super.key, required this.onSave});

  @override
  State<WoodCftTab> createState() => _WoodCftTabState();
}

class _WoodCftTabState extends State<WoodCftTab> {
  bool _isRoundLog = false; // false = Sawn Timber, true = Round Log (Hoppus)
  final _nameCtrl = TextEditingController(text: 'Segun / Mahogany');
  final _lengthFtCtrl = TextEditingController();
  final _lengthInCtrl = TextEditingController(text: '0');
  final _widthInCtrl = TextEditingController();
  final _thickInCtrl = TextEditingController();
  final _girthInCtrl = TextEditingController();
  final _pcsCtrl = TextEditingController(text: '1');
  final _rateCtrl = TextEditingController();

  double _val(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0.0;

  double get _totalLengthFt => _val(_lengthFtCtrl) + (_val(_lengthInCtrl) / 12.0);

  double get _cftPerPiece {
    final lenFt = _totalLengthFt;
    if (lenFt <= 0) return 0.0;
    if (_isRoundLog) {
      final girth = _val(_girthInCtrl);
      if (girth <= 0) return 0.0;
      // Hoppus formula: (Girth / 4)^2 * Length_ft / 144
      return pow(girth / 4.0, 2) * lenFt / 144.0;
    } else {
      final w = _val(_widthInCtrl);
      final t = _val(_thickInCtrl);
      if (w <= 0 || t <= 0) return 0.0;
      return (lenFt * w * t) / 144.0;
    }
  }

  double get _pcs => max(1.0, _val(_pcsCtrl));
  double get _totalCft => _cftPerPiece * _pcs;
  double get _totalPrice => _totalCft * _val(_rateCtrl);

  void _reset() {
    setState(() {
      _lengthFtCtrl.clear();
      _lengthInCtrl.text = '0';
      _widthInCtrl.clear();
      _thickInCtrl.clear();
      _girthInCtrl.clear();
      _pcsCtrl.text = '1';
      _rateCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Mode Switcher
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF161A20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Expanded(
                child: _modeBtn(
                  label: 'সাইজ কাঠ (Sawn)',
                  selected: !_isRoundLog,
                  onTap: () => setState(() => _isRoundLog = false),
                ),
              ),
              Expanded(
                child: _modeBtn(
                  label: 'গোল কাঠ (Round Log)',
                  selected: _isRoundLog,
                  onTap: () => setState(() => _isRoundLog = true),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Live Result Card
        _ResultBanner(
          accentColor: const Color(0xFFF59E0B),
          primaryLabel: 'TOTAL WOOD CFT',
          primaryValue: '${_totalCft.toStringAsFixed(3)} CFT',
          secondaryLabel: '1 PC: ${_cftPerPiece.toStringAsFixed(3)} CFT',
          priceValue: _totalPrice > 0 ? '৳ ${_totalPrice.toStringAsFixed(0)}' : '',
        ),
        const SizedBox(height: 14),

        _DarkInputField(
          controller: _nameCtrl,
          label: 'কাঠের নাম / বিবরণ (Wood Name)',
          keyboardType: TextInputType.text,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _DarkInputField(
                controller: _lengthFtCtrl,
                label: 'দৈর্ঘ্য - ফুট (Length ft)',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DarkInputField(
                controller: _lengthInCtrl,
                label: 'দৈর্ঘ্য - ইঞ্চি (in)',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (!_isRoundLog)
          Row(
            children: [
              Expanded(
                child: _DarkInputField(
                  controller: _widthInCtrl,
                  label: 'প্রস্থ - ইঞ্চি (Width in)',
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DarkInputField(
                  controller: _thickInCtrl,
                  label: 'পুরুত্ব/মোটা - ইঞ্চি (Thick in)',
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          )
        else
          _DarkInputField(
            controller: _girthInCtrl,
            label: 'গোল বেড় - ইঞ্চি (Girth / Ber in)',
            onChanged: (_) => setState(() {}),
          ),

        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DarkInputField(
                controller: _pcsCtrl,
                label: 'পিস সংখ্যা (Pieces)',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DarkInputField(
                controller: _rateCtrl,
                label: 'প্রতি CFT দর (Rate ৳)',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _reset,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
                label: const Text('Clear', style: TextStyle(color: Colors.white70)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _totalCft <= 0
                    ? null
                    : () {
                        final desc = _isRoundLog
                            ? '${_totalLengthFt.toStringAsFixed(2)}ft × G:${_girthInCtrl.text}" × ${_pcs.toInt()}pcs'
                            : '${_totalLengthFt.toStringAsFixed(2)}ft × ${_widthInCtrl.text}" × ${_thickInCtrl.text}" × ${_pcs.toInt()}pcs';
                        widget.onSave(
                          MeasurementRecord(
                            title: _nameCtrl.text.trim().isEmpty
                                ? 'Wood CFT'
                                : _nameCtrl.text.trim(),
                            detail: desc,
                            cft: _totalCft,
                            sqft: 0,
                            amount: _totalPrice,
                          ),
                        );
                      },
                icon: const Icon(Icons.add_circle_outline_rounded),
                label: const Text(
                  'Add to Estimate List',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _modeBtn({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF59E0B) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.black : Colors.white70,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 2: GLASS CFT & SQFT CALCULATOR
// ============================================================================
class GlassCalcTab extends StatefulWidget {
  final void Function(MeasurementRecord) onSave;
  const GlassCalcTab({super.key, required this.onSave});

  @override
  State<GlassCalcTab> createState() => _GlassCalcTabState();
}

class _GlassCalcTabState extends State<GlassCalcTab> {
  String _unit = 'INCH'; // INCH, MM, FEET
  double _thicknessMm = 5.0; // 4, 5, 6, 8, 10, 12
  final _widthCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _pcsCtrl = TextEditingController(text: '1');
  final _rateSqftCtrl = TextEditingController();

  double _val(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0.0;

  double _toFeet(double input) {
    if (_unit == 'INCH') return input / 12.0;
    if (_unit == 'MM') return input / 304.8;
    return input;
  }

  double get _pcs => max(1.0, _val(_pcsCtrl));

  double get _totalSqft {
    final wFt = _toFeet(_val(_widthCtrl));
    final hFt = _toFeet(_val(_heightCtrl));
    if (wFt <= 0 || hFt <= 0) return 0.0;
    return wFt * hFt * _pcs;
  }

  double get _totalGlassCft {
    // 1 foot = 304.8 mm -> thickness in feet = thicknessMm / 304.8
    final thickFt = _thicknessMm / 304.8;
    return _totalSqft * thickFt;
  }

  double get _totalPrice => _totalSqft * _val(_rateSqftCtrl);

  @override
  Widget build(BuildContext context) {
    final thicknesses = [3.0, 4.0, 5.0, 6.0, 8.0, 10.0, 12.0];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Unit Selector
        Row(
          children: ['INCH', 'MM', 'FEET'].map((u) {
            final active = _unit == u;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _unit = u),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFF161A20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active ? const Color(0xFF38BDF8) : Colors.white12,
                    ),
                  ),
                  child: Text(
                    u,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: active ? Colors.black : Colors.white70,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        _ResultBanner(
          accentColor: const Color(0xFF38BDF8),
          primaryLabel: 'GLASS SQFT & CFT (${_thicknessMm.toInt()}MM)',
          primaryValue: '${_totalSqft.toStringAsFixed(2)} SqFt',
          secondaryLabel: 'Volume: ${_totalGlassCft.toStringAsFixed(4)} CFT',
          priceValue: _totalPrice > 0 ? '৳ ${_totalPrice.toStringAsFixed(0)}' : '',
        ),
        const SizedBox(height: 14),

        const Text(
          'গ্লাসের পুরুত্ব (Glass Thickness in mm)',
          style: TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: thicknesses.map((mm) {
            final selected = _thicknessMm == mm;
            return ChoiceChip(
              label: Text('${mm.toInt()} mm'),
              selected: selected,
              selectedColor: const Color(0xFF38BDF8),
              labelStyle: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
              ),
              onSelected: (_) => setState(() => _thicknessMm = mm),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _DarkInputField(
                controller: _widthCtrl,
                label: 'প্রস্থ (Width - $_unit)',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DarkInputField(
                controller: _heightCtrl,
                label: 'উচ্চতা/দৈর্ঘ্য (Height - $_unit)',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _DarkInputField(
                controller: _pcsCtrl,
                label: 'পিস সংখ্যা (Pieces)',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DarkInputField(
                controller: _rateSqftCtrl,
                label: 'প্রতি SqFt দর (Rate ৳)',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF38BDF8),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _totalSqft <= 0
              ? null
              : () {
                  widget.onSave(
                    MeasurementRecord(
                      title: 'Glass (${_thicknessMm.toInt()}mm)',
                      detail:
                          '${_widthCtrl.text} × ${_heightCtrl.text} $_unit × ${_pcs.toInt()}pcs',
                      cft: _totalGlassCft,
                      sqft: _totalSqft,
                      amount: _totalPrice,
                    ),
                  );
                },
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text(
            'Add Glass to Estimate List',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TAB 3: SQFT & BOARD CALCULATOR (Plywood, Melamine, Partex, Veneer)
// ============================================================================
class SqftBoardTab extends StatefulWidget {
  final void Function(MeasurementRecord) onSave;
  const SqftBoardTab({super.key, required this.onSave});

  @override
  State<SqftBoardTab> createState() => _SqftBoardTabState();
}

class _SqftBoardTabState extends State<SqftBoardTab> {
  final _itemCtrl = TextEditingController(text: 'Plywood / Board');
  final _lenFtCtrl = TextEditingController();
  final _lenInCtrl = TextEditingController(text: '0');
  final _widFtCtrl = TextEditingController();
  final _widInCtrl = TextEditingController(text: '0');
  final _pcsCtrl = TextEditingController(text: '1');
  final _rateCtrl = TextEditingController();

  double _val(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0.0;

  double get _totalSqft {
    final l = _val(_lenFtCtrl) + (_val(_lenInCtrl) / 12.0);
    final w = _val(_widFtCtrl) + (_val(_widInCtrl) / 12.0);
    if (l <= 0 || w <= 0) return 0.0;
    return l * w * max(1.0, _val(_pcsCtrl));
  }

  // Standard 8x4 ft board = 32 SqFt
  double get _boardsNeeded => _totalSqft / 32.0;
  double get _totalPrice => _totalSqft * _val(_rateCtrl);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ResultBanner(
          accentColor: const Color(0xFF10B981),
          primaryLabel: 'TOTAL AREA (SQFT)',
          primaryValue: '${_totalSqft.toStringAsFixed(2)} SqFt',
          secondaryLabel:
              '8×4 Board: ${_boardsNeeded.toStringAsFixed(2)} Sheets',
          priceValue: _totalPrice > 0 ? '৳ ${_totalPrice.toStringAsFixed(0)}' : '',
        ),
        const SizedBox(height: 14),

        _DarkInputField(
          controller: _itemCtrl,
          label: 'বোর্ড / কাজের নাম (Item Name)',
          keyboardType: TextInputType.text,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _DarkInputField(
                controller: _lenFtCtrl,
                label: 'দৈর্ঘ্য - ফুট (Length ft)',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DarkInputField(
                controller: _lenInCtrl,
                label: 'দৈর্ঘ্য - ইঞ্চি (in)',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _DarkInputField(
                controller: _widFtCtrl,
                label: 'প্রস্থ - ফুট (Width ft)',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DarkInputField(
                controller: _widInCtrl,
                label: 'প্রস্থ - ইঞ্চি (in)',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _DarkInputField(
                controller: _pcsCtrl,
                label: 'পিস সংখ্যা (Pieces)',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DarkInputField(
                controller: _rateCtrl,
                label: 'প্রতি SqFt দর (Rate ৳)',
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _totalSqft <= 0
              ? null
              : () {
                  widget.onSave(
                    MeasurementRecord(
                      title: _itemCtrl.text.trim().isEmpty
                          ? 'Board SqFt'
                          : _itemCtrl.text.trim(),
                      detail:
                          '${_lenFtCtrl.text}ft ${_lenInCtrl.text}in × ${_widFtCtrl.text}ft ${_widInCtrl.text}in',
                      cft: 0,
                      sqft: _totalSqft,
                      amount: _totalPrice,
                    ),
                  );
                },
          icon: const Icon(Icons.add_circle_outline_rounded),
          label: const Text(
            'Add SqFt to Estimate List',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TAB 4: INSTANT UNIT CONVERTER (mm <-> Inches + Fraction <-> Feet <-> CM)
// ============================================================================
class UnitConverterTab extends StatefulWidget {
  const UnitConverterTab({super.key});

  @override
  State<UnitConverterTab> createState() => _UnitConverterTabState();
}

class _UnitConverterTabState extends State<UnitConverterTab> {
  final _mmCtrl = TextEditingController();
  final _inchCtrl = TextEditingController();
  final _feetCtrl = TextEditingController();
  final _cmCtrl = TextEditingController();
  bool _updating = false;

  void _fromMm(String text) {
    if (_updating) return;
    _updating = true;
    final mm = double.tryParse(text);
    if (mm == null) {
      _inchCtrl.clear();
      _feetCtrl.clear();
      _cmCtrl.clear();
    } else {
      _inchCtrl.text = (mm / 25.4).toStringAsFixed(4);
      _feetCtrl.text = (mm / 304.8).toStringAsFixed(4);
      _cmCtrl.text = (mm / 10.0).toStringAsFixed(3);
    }
    setState(() {});
    _updating = false;
  }

  void _fromInch(String text) {
    if (_updating) return;
    _updating = true;
    final inch = double.tryParse(text);
    if (inch == null) {
      _mmCtrl.clear();
      _feetCtrl.clear();
      _cmCtrl.clear();
    } else {
      _mmCtrl.text = (inch * 25.4).toStringAsFixed(2);
      _feetCtrl.text = (inch / 12.0).toStringAsFixed(4);
      _cmCtrl.text = (inch * 2.54).toStringAsFixed(3);
    }
    setState(() {});
    _updating = false;
  }

  void _fromFeet(String text) {
    if (_updating) return;
    _updating = true;
    final ft = double.tryParse(text);
    if (ft == null) {
      _mmCtrl.clear();
      _inchCtrl.clear();
      _cmCtrl.clear();
    } else {
      _inchCtrl.text = (ft * 12.0).toStringAsFixed(3);
      _mmCtrl.text = (ft * 304.8).toStringAsFixed(2);
      _cmCtrl.text = (ft * 30.48).toStringAsFixed(2);
    }
    setState(() {});
    _updating = false;
  }

  void _fromCm(String text) {
    if (_updating) return;
    _updating = true;
    final cm = double.tryParse(text);
    if (cm == null) {
      _mmCtrl.clear();
      _inchCtrl.clear();
      _feetCtrl.clear();
    } else {
      _mmCtrl.text = (cm * 10.0).toStringAsFixed(2);
      _inchCtrl.text = (cm / 2.54).toStringAsFixed(4);
      _feetCtrl.text = (cm / 30.48).toStringAsFixed(4);
    }
    setState(() {});
    _updating = false;
  }

  // Convert decimal inches into carpenter fraction (nearest 1/16")
  String get _carpenterFraction {
    final inch = double.tryParse(_inchCtrl.text);
    if (inch == null || inch <= 0) return '-';
    final whole = inch.floor();
    final frac = inch - whole;
    final sixteenths = (frac * 16).round();
    if (sixteenths == 0) return '$whole"';
    if (sixteenths == 16) return '${whole + 1}"';

    int num = sixteenths;
    int den = 16;
    while (num % 2 == 0 && den % 2 == 0) {
      num ~/= 2;
      den ~/= 2;
    }
    return whole > 0 ? '$whole $num/$den"' : '$num/$den"';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161A20),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFF38BDF8).withOpacity(0.4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'মিস্ত্রি স্কেল (Carpenter Fraction)',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'সুতা / ইঞ্চি ফ্র্যাকশন (1/16")',
                    style: TextStyle(fontSize: 11, color: Colors.white38),
                  ),
                ],
              ),
              Text(
                _carpenterFraction,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF38BDF8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        _DarkInputField(
          controller: _mmCtrl,
          label: 'Millimeter (mm)',
          onChanged: _fromMm,
        ),
        const SizedBox(height: 10),
        _DarkInputField(
          controller: _inchCtrl,
          label: 'Inches (in)',
          onChanged: _fromInch,
        ),
        const SizedBox(height: 10),
        _DarkInputField(
          controller: _feetCtrl,
          label: 'Feet (ft)',
          onChanged: _fromFeet,
        ),
        const SizedBox(height: 10),
        _DarkInputField(
          controller: _cmCtrl,
          label: 'Centimeter (cm)',
          onChanged: _fromCm,
        ),
        const SizedBox(height: 18),

        // Quick Furniture Reference Chart
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF161A20),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QUICK FURNITURE REFERENCE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Color(0xFFF59E0B),
                ),
              ),
              SizedBox(height: 8),
              Text('• 1 সুতা (Suta) = 1/8 inch = 3.175 mm',
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
              Text('• 12 mm Board = 0.472 inch (প্রায় ১/২ ইঞ্চি)',
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
              Text('• 18 mm Board = 0.709 inch (প্রায় ৩/৪ ইঞ্চি)',
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
              Text('• 1 Full Board (8ft × 4ft) = 32 SqFt',
                  style: TextStyle(fontSize: 12, color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TAB 5: SAVED ESTIMATE / GRAND TOTAL LIST
// ============================================================================
class EstimateListTab extends StatelessWidget {
  final List<MeasurementRecord> records;
  final void Function(int) onDelete;
  final VoidCallback onClear;

  const EstimateListTab({
    super.key,
    required this.records,
    required this.onDelete,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final totalCft = records.fold<double>(0, (sum, r) => sum + r.cft);
    final totalSqft = records.fold<double>(0, (sum, r) => sum + r.sqft);
    final totalMoney = records.fold<double>(0, (sum, r) => sum + r.amount);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161A20),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFF59E0B).withOpacity(0.45),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _summaryItem('TOTAL CFT', totalCft.toStringAsFixed(3)),
              _summaryItem('TOTAL SQFT', totalSqft.toStringAsFixed(2)),
              _summaryItem('TOTAL BILL', '৳${totalMoney.toStringAsFixed(0)}'),
            ],
          ),
        ),
        if (records.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.delete_sweep_rounded,
                      color: Colors.redAccent, size: 18),
                  label: const Text('Clear All',
                      style: TextStyle(color: Colors.redAccent)),
                ),
              ],
            ),
          ),
        Expanded(
          child: records.isEmpty
              ? const Center(
                  child: Text(
                    'এখনো কোনো হিসাব লিস্টে যোগ করা হয়নি',
                    style: TextStyle(color: Colors.white54),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: records.length,
                  itemBuilder: (context, idx) {
                    final r = records[idx];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161A20),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  r.detail,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  [
                                    if (r.cft > 0)
                                      '${r.cft.toStringAsFixed(3)} CFT',
                                    if (r.sqft > 0)
                                      '${r.sqft.toStringAsFixed(2)} SqFt',
                                    if (r.amount > 0)
                                      '৳${r.amount.toStringAsFixed(0)}',
                                  ].join('  •  '),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFF59E0B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Colors.white38),
                            onPressed: () => onDelete(idx),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _summaryItem(String label, String val) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SHARED WIDGETS
// ============================================================================
class _ResultBanner extends StatelessWidget {
  final Color accentColor;
  final String primaryLabel;
  final String primaryValue;
  final String secondaryLabel;
  final String priceValue;

  const _ResultBanner({
    required this.accentColor,
    required this.primaryLabel,
    required this.primaryValue,
    required this.secondaryLabel,
    required this.priceValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(0.45)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                primaryLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                primaryValue,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                secondaryLabel,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          if (priceValue.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                priceValue,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DarkInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  const _DarkInputField({
    required this.controller,
    required this.label,
    this.keyboardType = const TextInputType.numberWithOptions(decimal: true),
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12, color: Colors.white60),
        filled: true,
        fillColor: const Color(0xFF161A20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
        ),
      ),
    );
  }
}
