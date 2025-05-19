import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/family_circles/controllers/family_circles_controller.dart';
import 'package:lopako_app_lis/features/family_circles/models/family_circle_model.dart';
import 'package:lopako_app_lis/features/routines/screens/discover_routines_screen.dart';
import 'package:lopako_app_lis/generated/l10n.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final FamilyCirclesController _familyCirclesController = FamilyCirclesController();

  final double _minSheetExtent = 0.2;
  final double _maxSheetExtent = 0.6;
  double _currentExtent;

  final double _hideLogoStart = 0.15;
  final double _hideLogoEnd = 0.35;

  _HomeScreenState() : _currentExtent = 0.2;

  bool _hasResetScroll = false;

  bool _isFamilyCircleLoading = false;
  FamilyCircle? _currentFamilyCircle;
  List<FamilyCircle> _familyCircles = [];

  late final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _fetchFamilyCircles();
    _sheetController.addListener(_onSheetScroll);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetScroll);
    super.dispose();
  }

  Future<void> _fetchFamilyCircles() async {
    setState(() {
      _isFamilyCircleLoading = true;
    });
    _familyCircles = await _familyCirclesController.getFamilyCircles();
    _currentFamilyCircle = await _familyCirclesController.getCurrentFamilyCircle();
    setState(() {
      _isFamilyCircleLoading = false;
    });
  }

  Future<void> _switchFamilyCircle(FamilyCircle? selected) async {
    if (selected == null) return;
    setState(() {
      _isFamilyCircleLoading = true;
    });
    await _familyCirclesController.switchFamilyCircle(selected);
    setState(() {
      _currentFamilyCircle = selected;
      _isFamilyCircleLoading = false;
    });
  }

  void _onSheetScroll() {
    final e = _sheetController.size.clamp(_minSheetExtent, _maxSheetExtent);
    if ((e - _currentExtent).abs() > 0.5) {
      setState(() => _currentExtent = e);
    }
  }

  Widget _buildHeader(BuildContext context) {
    final localizations = S.of(context);

    final extent = _sheetController.isAttached
      ? _sheetController.size.clamp(_minSheetExtent, _maxSheetExtent)
      : _minSheetExtent;
    final headerHeight = MediaQuery.of(context).size.height * (1 - extent);

    final t = (extent - _minSheetExtent) / (_maxSheetExtent - _minSheetExtent);
    final logoOpacity = 1 - ((t - 0.15) / (0.35 - 0.15)).clamp(0.0, 1.0);
    final logoSize = 120 + (140 - 120) * logoOpacity;
    final logoTop = 80 - (80 - 32) * t;
    final headerPadT = 220 - (220 - 48) * t;
    final headerPadB = 100 - (100 - 24) * t;

    final familyCircleName = _currentFamilyCircle != null
      ? localizations.familyOfPatientName(_currentFamilyCircle!.patientName)
      : localizations.selectFamilyCircle;

    FamilyCircle? dropdownValue;
    if (_currentFamilyCircle != null) {
      dropdownValue = _familyCircles.firstWhere(
            (fc) => fc.id == _currentFamilyCircle!.id,
        orElse: () => _familyCircles.first,
      );
    }

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            top: logoTop, left: 0, right: 0,
            child: Opacity(
              opacity: logoOpacity,
              child: Center(
                child: SizedBox(
                  width: logoSize, height: logoSize,
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: headerPadT, bottom: headerPadB),
            child: _isFamilyCircleLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  if (_familyCircles.length > 1)
                    DropdownButton<FamilyCircle>(
                      value: dropdownValue,
                      items: _familyCircles.map((fc) {
                        return DropdownMenuItem(
                          value: fc,
                          child: Text(localizations.familyOfPatientName(fc.patientName)),
                        );
                      }).toList(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.neutral[700],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      padding: const EdgeInsets.only(left: 16, right: 8),
                      icon: const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: FaIcon(FontAwesomeIcons.angleDown, size: 16)
                      ),
                      underline: const SizedBox(),
                      onChanged: _switchFamilyCircle,
                      elevation: 0,
                      dropdownColor: AppColors.neutral[50],
                    ),
                  if (_familyCircles.length <= 1)
                    Text(
                      familyCircleName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.neutral[700],
                      ),
                    ),
                  const Expanded(
                    child: Center(
                      child: Text('Hello World',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = (_currentExtent - _minSheetExtent) / (_maxSheetExtent - _minSheetExtent);
    double hideLogoProgress = (t - _hideLogoStart) / (_hideLogoEnd - _hideLogoStart);
    hideLogoProgress = hideLogoProgress.clamp(0.0, 1.0);

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _sheetController,
            builder: (context, _) => _buildHeader(context),
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _minSheetExtent,
            minChildSize: _minSheetExtent,
            maxChildSize: _maxSheetExtent,
            snap: true,
            snapSizes: [_minSheetExtent, _maxSheetExtent],
            builder: (context, scrollController) {
              if (!_hasResetScroll) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  scrollController.jumpTo(0);
                });
                _hasResetScroll = true;
              }
              return LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.neutral[200]!,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.only(top: 16, bottom: 16),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight - 32,
                              ),
                              child: _isFamilyCircleLoading
                                ? const Center(child: CircularProgressIndicator())
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Text("Hello World", style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.neutral[700],
                                        )),
                                      ),
                                    ]
                                  )
                            ),
                        ),
                        // Indicador de arrastre
                        Positioned(
                          top: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.neutral[200],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isFamilyCircleLoading
          ? null
          : () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => const DiscoverRoutinesScreen(),
            ));
          },
        child: FaIcon(FontAwesomeIcons.magnifyingGlass),
      )
    );
  }
}