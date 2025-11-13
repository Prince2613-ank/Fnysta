import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart' as pie;
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../../../../theme/theme_provider.dart';
import 'package:fl_chart/fl_chart.dart'; // For the line chart

class SipCalculatorScreen extends StatefulWidget {
  const SipCalculatorScreen({super.key});

  @override
  State<SipCalculatorScreen> createState() => _SipCalculatorScreenState();
}

class _SipCalculatorScreenState extends State<SipCalculatorScreen> {
  double _monthlyInvestment = 5000;
  double _investmentPeriod = 10; // in years
  double _expectedReturnRate = 12; // in % p.a.

  double _totalInvested = 0;
  double _futureValue = 0;
  double _totalGains = 0;

  List<SipDataPoint> _sipData = [];

  @override
  void initState() {
    super.initState();
    _calculateSip();
  }

  // Helper function for smart number formatting (Lakhs & Crores)
  String _formatLargeIndianNumber(double number) {
    if (number.abs() < 100000) {
      return '₹${NumberFormat.decimalPattern('en_IN').format(number.round())}';
    } else if (number.abs() < 10000000) {
      return '₹${(number / 100000).toStringAsFixed(2)}L';
    } else {
      return '₹${(number / 10000000).toStringAsFixed(2)}Cr';
    }
  }

  // Helper function to find a visually pleasing interval for chart axes
  double _getCleanInterval(double maxValue) {
    if (maxValue <= 0) return 1;
    int magnitude = pow(10, (log(maxValue) / ln10).floor()).toInt();
    double residual = maxValue / magnitude;
    double step;
    if (residual < 1.5) {
      step = 0.25;
    } else if (residual < 3) {
      step = 0.5;
    } else if (residual < 7) {
      step = 1.0;
    } else {
      step = 2.0;
    }
    return step * magnitude;
  }

  // Helper to get a smart interval for the bottom (year) axis
  double _getBottomTitleInterval(double period) {
    if (period <= 10) return 2;
    if (period <= 20) return 5;
    return 10;
  }

  void _calculateSip() {
    final double p = _monthlyInvestment;
    final double annualRate = _expectedReturnRate;
    final int years = _investmentPeriod.toInt();

    if (p > 0 && annualRate >= 0 && years > 0) {
      final double r = annualRate / 12 / 100; // Monthly interest rate
      final int n = years * 12; // Tenure in months
      _totalInvested = p * n;
      if (r > 0) {
        _futureValue = p * ((pow(1 + r, n) - 1) / r) * (1 + r);
      } else {
        _futureValue = _totalInvested;
      }
      _totalGains = _futureValue - _totalInvested;
      _generateSipData(p, annualRate, years);
    } else {
      _totalInvested = 0;
      _futureValue = 0;
      _totalGains = 0;
      _sipData = [];
    }
    setState(() {});
  }

  void _generateSipData(
      double monthlyInvestment, double annualRate, int years) {
    _sipData = [];
    double currentInvested = 0;
    double currentValue = 0;
    final double r = annualRate / 12 / 100; // Monthly interest rate
    for (int i = 1; i <= years; i++) {
      int months = i * 12;
      currentInvested = monthlyInvestment * months;
      if (r > 0) {
        currentValue =
            monthlyInvestment * ((pow(1 + r, months) - 1) / r) * (1 + r);
      } else {
        currentValue = currentInvested;
      }
      double gains = currentValue - currentInvested;
      _sipData.add(SipDataPoint(
        year: i,
        invested: currentInvested,
        value: currentValue,
        gains: gains,
      ));
    }
  }

  void _resetCalculator() {
    setState(() {
      _monthlyInvestment = 5000;
      _investmentPeriod = 10;
      _expectedReturnRate = 12;
      _calculateSip();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1E242A);
    final primaryColor =
        isDarkMode ? Colors.cyanAccent : const Color(0xFF0052D4);
    final accentColor =
        isDarkMode ? Colors.greenAccent.shade400 : Colors.green.shade600;

    Map<String, double> dataMap = {
      "Invested": _totalInvested,
      "Gains": _totalGains,
    };

    List<Color> colorList = [primaryColor, accentColor];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF232526), const Color(0xFF414345)]
                : [const Color(0xFFA1C4FD), const Color(0xFFC2E9FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(textColor),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _buildSummarySection(
                          textColor, primaryColor, accentColor),
                      const SizedBox(height: 24),
                      _buildInputSection(textColor, primaryColor),
                      const SizedBox(height: 24),
                      if (_totalInvested > 0)
                        _buildPieChartCard(textColor, dataMap, colorList,
                            isDarkMode, _futureValue),
                      const SizedBox(height: 24),
                      if (_sipData.isNotEmpty)
                        _buildLineChartCard(
                            textColor, primaryColor, accentColor),
                      const SizedBox(height: 24),
                      if (_sipData.isNotEmpty)
                        _buildBreakdownTable(
                            textColor, primaryColor, accentColor),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 16.0, 8.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: textColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SIP Calculator',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  'Visualize your wealth growth',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
      Color textColor, Color primaryColor, Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Invested',
            value: _formatLargeIndianNumber(_totalInvested),
            icon: Icons.account_balance_wallet,
            color: primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Future Value',
            value: _formatLargeIndianNumber(_futureValue),
            icon: Icons.trending_up,
            color: accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GlassmorphicContainer(
      isDarkMode: isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontSize: 14,
                    color: (isDarkMode ? Colors.white : Colors.black)
                        .withOpacity(0.8)),
              ),
              Icon(icon, color: color, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(Color textColor, Color primaryColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GlassmorphicContainer(
      isDarkMode: isDarkMode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Investment Details',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              TextButton.icon(
                onPressed: _resetCalculator,
                icon: Icon(Icons.refresh, size: 18, color: primaryColor),
                label: Text(
                  'Reset',
                  style: TextStyle(color: primaryColor, fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  backgroundColor: primaryColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SliderWithInput(
            label: 'Monthly Investment',
            value: _monthlyInvestment,
            min: 500,
            max: 100000,
            divisions: 199,
            onChanged: (value) {
              setState(() {
                _monthlyInvestment = value;
                _calculateSip();
              });
            },
            textColor: textColor,
            activeColor: primaryColor,
          ),
          const SizedBox(height: 20),
          _SliderWithInput(
            label: 'Investment Period (Years)',
            value: _investmentPeriod,
            min: 1,
            max: 40,
            divisions: 39,
            onChanged: (value) {
              setState(() {
                _investmentPeriod = value;
                _calculateSip();
              });
            },
            textColor: textColor,
            activeColor: primaryColor,
          ),
          const SizedBox(height: 20),
          _SliderWithInput(
            label: 'Expected Annual Return (%)',
            value: _expectedReturnRate,
            min: 1,
            max: 30,
            divisions: 29,
            onChanged: (value) {
              setState(() {
                _expectedReturnRate = value;
                _calculateSip();
              });
            },
            textColor: textColor,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard(Color textColor, Map<String, double> dataMap,
      List<Color> colorList, bool isDarkMode, double totalValue) {
    return GlassmorphicContainer(
      isDarkMode: isDarkMode,
      child: Column(
        children: [
          Text('Wealth Breakdown',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 24),
          pie.PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(milliseconds: 800),
            chartLegendSpacing: 40,
            chartRadius: MediaQuery.of(context).size.width / 2.8,
            colorList: colorList,
            initialAngleInDegree: -90,
            chartType: pie.ChartType.ring,
            ringStrokeWidth: 32,
            centerText: "Total\n${_formatLargeIndianNumber(totalValue)}",
            centerTextStyle: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            legendOptions: const pie.LegendOptions(
              showLegends: false,
            ),
            chartValuesOptions: pie.ChartValuesOptions(
              showChartValueBackground: false,
              showChartValues: true,
              showChartValuesInPercentage: true,
              // 🎯 MODIFIED: Show chart values outside the pie chart
              showChartValuesOutside: true,
              decimalPlaces: 1,
              // 🎯 MODIFIED: Use theme-aware text color
              chartValueStyle: TextStyle(
                  fontWeight: FontWeight.bold, color: textColor, fontSize: 12),
            ),
            gradientList: [
              [colorList[0].withOpacity(0.7), colorList[0]],
              [colorList[1].withOpacity(0.7), colorList[1]],
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend(
                  color: colorList[0], text: 'Invested', textColor: textColor),
              const SizedBox(width: 24),
              _buildChartLegend(
                  color: colorList[1], text: 'Gains', textColor: textColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartCard(
      Color textColor, Color primaryColor, Color accentColor) {
    List<FlSpot> totalInvestmentSpots = _sipData
        .map((data) => FlSpot(data.year.toDouble(), data.invested))
        .toList();

    List<FlSpot> futureValueSpots = _sipData
        .map((data) => FlSpot(data.year.toDouble(), data.value))
        .toList();

    double maxY = _futureValue * 1.1;
    final yInterval = _getCleanInterval(maxY);
    final xInterval = _getBottomTitleInterval(_investmentPeriod);

    return GlassmorphicContainer(
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
      child: Column(
        children: [
          Text(
            'Growth Over Time',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.6,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: yInterval,
                  verticalInterval: xInterval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: textColor.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: textColor.withOpacity(0.1),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: xInterval,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        space: 8.0,
                        child: Text(
                          '${value.toInt()}Y',
                          style: TextStyle(
                              color: textColor.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      interval: yInterval,
                      getTitlesWidget: (value, meta) => SideTitleWidget(
                        meta: meta,
                        child: Text(
                          _formatLargeIndianNumber(value),
                          style: TextStyle(
                              color: textColor.withOpacity(0.8),
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: _investmentPeriod,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  _getLineChartBarData(totalInvestmentSpots, primaryColor),
                  _getLineChartBarData(futureValueSpots, accentColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _getLineChartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      shadow: Shadow(
          color: color.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4)),
    );
  }

  Widget _buildChartLegend({
    required Color color,
    required String text,
    required Color textColor,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
              color: textColor.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildBreakdownTable(
      Color textColor, Color primaryColor, Color accentColor) {
    final headerStyle = TextStyle(
      color: textColor.withOpacity(0.7),
      fontWeight: FontWeight.bold,
      fontSize: 13,
    );
    final cellStyle = TextStyle(
      color: textColor,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );

    return GlassmorphicContainer(
      isDarkMode: Theme.of(context).brightness == Brightness.dark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yearly Breakdown',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(flex: 1, child: Text('Year', style: headerStyle)),
                Expanded(
                    flex: 2,
                    child: Text('Invested',
                        style: headerStyle, textAlign: TextAlign.right)),
                Expanded(
                    flex: 2,
                    child: Text('Value',
                        style: headerStyle, textAlign: TextAlign.right)),
                Expanded(
                    flex: 2,
                    child: Text('Gains',
                        style: headerStyle, textAlign: TextAlign.right)),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _sipData.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, color: textColor.withOpacity(0.1)),
            itemBuilder: (context, index) {
              final data = _sipData[index];
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text(data.year.toString(), style: cellStyle)),
                    Expanded(
                        flex: 2,
                        child: Text(_formatLargeIndianNumber(data.invested),
                            style: cellStyle, textAlign: TextAlign.right)),
                    Expanded(
                        flex: 2,
                        child: Text(_formatLargeIndianNumber(data.value),
                            style: cellStyle.copyWith(color: primaryColor),
                            textAlign: TextAlign.right)),
                    Expanded(
                        flex: 2,
                        child: Text(_formatLargeIndianNumber(data.gains),
                            style: cellStyle.copyWith(color: accentColor),
                            textAlign: TextAlign.right)),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class SipDataPoint {
  final int year;
  final double invested;
  final double value;
  final double gains;

  SipDataPoint({
    required this.year,
    required this.invested,
    required this.value,
    required this.gains,
  });
}

class _SliderWithInput extends StatefulWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;
  final Color textColor;
  final Color activeColor;

  const _SliderWithInput({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.textColor,
    required this.activeColor,
  });

  @override
  State<_SliderWithInput> createState() => _SliderWithInputState();
}

class _SliderWithInputState extends State<_SliderWithInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _updateText(widget.value);
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _updateFromText(_controller.text);
    }
  }

  void _updateFromText(String text) {
    double? newValue =
        double.tryParse(text.replaceAll('₹', '').replaceAll(',', ''));
    if (newValue != null) {
      final clampedValue = newValue.clamp(widget.min, widget.max);
      if (clampedValue != widget.value) {
        widget.onChanged(clampedValue);
      }
      _updateText(clampedValue);
    } else {
      _updateText(widget.value);
    }
  }

  void _updateText(double value) {
    final formatter = NumberFormat.decimalPattern('en_IN');
    String text = '₹${formatter.format(value.round())}';
    if (widget.label.contains('%')) {
      text = '${value.toStringAsFixed(1)}%';
    } else if (widget.label.contains('Years')) {
      text = value.toInt().toString();
    }

    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  @override
  void didUpdateWidget(covariant _SliderWithInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && !_focusNode.hasFocus) {
      _updateText(widget.value);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label,
                style: TextStyle(
                    color: widget.textColor.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            SizedBox(
              width: 120,
              height: 40,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: widget.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.black.withOpacity(0.2)
                      : Colors.white.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: _updateFromText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: widget.activeColor,
            inactiveTrackColor: widget.activeColor.withOpacity(0.3),
            thumbColor: Colors.white,
            overlayColor: widget.activeColor.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
            trackHeight: 6.0,
          ),
          child: Slider(
            value: widget.value,
            min: widget.min,
            max: widget.max,
            onChanged: widget.onChanged,
          ),
        ),
      ],
    );
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final bool isDarkMode;
  const GlassmorphicContainer(
      {super.key, required this.child, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
