import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lopako_app_lis/core/constants/app_colors.dart';
import 'package:lopako_app_lis/features/routines/screens/discover_routines_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final double _minSheetExtent = 0.2;
  final double _maxSheetExtent = 0.6;
  double _currentExtent;

  final double _hideLogoStart = 0.15;
  final double _hideLogoEnd = 0.35;
  final double _logoMaxSize = 140;
  final double _logoMinSize = 120;
  final double _paddingMaxSize = 120;
  final double _paddingMinSize = 0;

  _HomeScreenState() : _currentExtent = 0.2;

  bool _hasResetScroll = false;

  late final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetScroll);
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetScroll);
    super.dispose();
  }

  void _onSheetScroll() {
    final e = _sheetController.size.clamp(_minSheetExtent, _maxSheetExtent);
    if ((e - _currentExtent).abs() > 0.5) {
      setState(() => _currentExtent = e);
    }
  }

  Widget _buildHeader(BuildContext context) {
    final extent = _sheetController.isAttached
      ? _sheetController.size.clamp(_minSheetExtent, _maxSheetExtent)
      : _minSheetExtent;
    final headerHeight = MediaQuery.of(context).size.height * (1 - extent);

    final t = (extent - _minSheetExtent) / (_maxSheetExtent - _minSheetExtent);
    final logoOpacity = 1 - ((t - 0.15) / (0.35 - 0.15)).clamp(0.0, 1.0);
    final logoSize = 120 + (140 - 120) * logoOpacity;
    final logoPad  = 120 - (120 * t);

    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: logoPad),
            child: const Center(
              child: Text('Hello World',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          Positioned(
            top: 80, left: 0, right: 0,
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
                    // Lista de ítems con padding para dejar espacio al indicador
                    ListView.builder(
                      controller: scrollController,
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('Item ${index + 1}'),
                        );
                      },
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => const DiscoverRoutinesScreen(),
          ));
        },
        child: FaIcon(FontAwesomeIcons.magnifyingGlass),
      )
    );
  }
}