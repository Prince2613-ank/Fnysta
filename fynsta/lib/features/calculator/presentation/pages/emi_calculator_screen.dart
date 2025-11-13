import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart' as pie;
import 'package:provider/provider.dart';
import 'dart:math';
// 🎯 ADDED: Import for number formatting
import 'package:intl/intl.dart';
import '../../../../theme/theme_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class EmiCalculatorScreen extends StatefulWidget {
  const EmiCalculatorScreen({super.key});

  @override
  State<EmiCalculatorScreen> createState() => _EmiCalculatorScreenState();
}

class _EmiCalculatorScreenState extends State<EmiCalculatorScreen> {
  double _loanAmount = 1000000;
  double _annualRate = 8.5;
  double _tenureYears = 5;

  double _monthlyEmi = 0;
  double _totalInterest = 0;
  double _totalPayment = 0;
  List<EmiDataPoint> _emiData = [];

  @override
  void initState() {
    super.initState();
    _calculateEmi();
  }

  void _calculateEmi() {
    final double p = _loanAmount;
    final double annualRate = _annualRate;
    final int years = _tenureYears.toInt();

    if (p > 0 && annualRate > 0 && years > 0) {
      final double r = annualRate / 12 / 100; // Monthly interest rate
      final int n = years * 12; // Tenure in months

      _monthlyEmi = (p * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
      _totalPayment = _monthlyEmi * n;
      _totalInterest = _totalPayment - p;
      _generateEmiData(p, r, n);
    } else {
      _monthlyEmi = 0;
      _totalInterest = 0;
      _totalPayment = 0;
      _emiData = [];
    }
    setState(() {});
  }

  void _generateEmiData(double principal, double monthlyRate, int totalMonths) {
    List<EmiDataPoint> data = [];
    double remainingPrincipal = principal;

    for (int year = 1; year <= (totalMonths / 12); year++) {
      double yearlyInterestPaid = 0;
      double yearlyPrincipalPaid = 0;

      for (int month = 1; month <= 12; month++) {
        if ((year - 1) * 12 + month > totalMonths) break;
        double interestForMonth = remainingPrincipal * monthlyRate;
        double principalForMonth = _monthlyEmi - interestForMonth;
        remainingPrincipal -= principalForMonth;
        yearlyInterestPaid += interestForMonth;
        yearlyPrincipalPaid += principalForMonth;
      }
      data.add(EmiDataPoint(
        year: year,
        principalPaid: yearlyPrincipalPaid,
        interestPaid: yearlyInterestPaid,
        balance: remainingPrincipal > 0 ? remainingPrincipal : 0,
      ));
    }
    _emiData = data;
  }

  void _resetCalculator() {
    setState(() {
      _loanAmount = 1000000;
      _annualRate = 8.5;
      _tenureYears = 5;
      _calculateEmi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final primaryColor =
        isDarkMode ? Colors.blue[300] : const Color.fromARGB(255, 80, 96, 118);
    final accentColor = isDarkMode ? Colors.red[300]! : Colors.redAccent;

    final List<LinearGradient> lightModeGradients = [
      const LinearGradient(
          colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFFF1F5FF), Color(0xFFE0E8FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      const LinearGradient(
          colors: [Color(0xFFF0FFF4), Color(0xFFE6FCF5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
    ];

    final List<LinearGradient> darkModeGradients = [
      LinearGradient(
          colors: [const Color(0xFF262D34), const Color(0xFF1E242A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      LinearGradient(
          colors: [const Color(0xFF2C3E50), const Color(0xFF1D2B3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      LinearGradient(
          colors: [const Color(0xFF1E3A3A), const Color(0xFF2D545E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
    ];
    final cardGradients = isDarkMode ? darkModeGradients : lightModeGradients;

    Map<String, double> dataMap = {
      "Principal": _loanAmount,
      "Interest": _totalInterest,
    };
    List<Color> colorList = [primaryColor!, accentColor];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  colors: [
                    Color(0xFF1A237E),
                    Color(0xFF4A148C),
                    Color(0xFF004D40)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Color(0xFFE0C3FC),
                    Color(0xFF8EC5FC),
                    Color(0xFF84FAB0)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: 8.0,
                  right: 16.0,
                  bottom: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: textColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text('EMI Calculator',
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSummarySection(cardGradients[0], textColor,
                          primaryColor, accentColor),
                      const SizedBox(height: 24),
                      _buildInputSection(
                          cardGradients[1], textColor, primaryColor),
                      const SizedBox(height: 24),
                      if (_totalPayment > 0)
                        _buildLineChartCard(cardGradients[2], textColor,
                            primaryColor, accentColor),
                      const SizedBox(height: 24),
                      if (_totalPayment > 0)
                        _buildPieChartCard(
                            cardGradient: cardGradients[2],
                            textColor: textColor,
                            dataMap: dataMap,
                            colorList: colorList,
                            isDarkMode: isDarkMode),
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

  Widget _buildSummarySection(Gradient cardGradient, Color textColor,
      Color primaryColor, Color accentColor) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
              title: 'Monthly EMI',
              value:
                  '₹ ${NumberFormat.decimalPattern('en_IN').format(_monthlyEmi.round())}',
              cardGradient: cardGradient,
              textColor: textColor,
              valueColor: primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
              title: 'Total Payment',
              value:
                  '₹ ${NumberFormat.decimalPattern('en_IN').format(_totalPayment.round())}',
              cardGradient: cardGradient,
              textColor: textColor,
              valueColor: textColor.withOpacity(0.8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
              title: 'Total Interest',
              value:
                  '₹ ${NumberFormat.decimalPattern('en_IN').format(_totalInterest.round())}',
              cardGradient: cardGradient,
              textColor: textColor,
              valueColor: accentColor),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required Gradient cardGradient,
    required Color textColor,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  TextStyle(fontSize: 12, color: textColor.withOpacity(0.7))),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: valueColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildInputSection(
      Gradient cardGradient, Color textColor, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹ Loan Details',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
              TextButton.icon(
                onPressed: _resetCalculator,
                icon: Icon(Icons.refresh, size: 18, color: primaryColor),
                label: Text('Reset', style: TextStyle(color: primaryColor)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SliderWithInput(
            label: 'Loan Amount',
            value: _loanAmount,
            min: 10000,
            max: 5000000,
            divisions: 499,
            onChanged: (value) {
              setState(() {
                _loanAmount = value;
                _calculateEmi();
              });
            },
            textColor: textColor,
            activeColor: primaryColor,
          ),
          const SizedBox(height: 16),
          _SliderWithInput(
            label: 'Loan Tenure (Years)',
            value: _tenureYears,
            min: 1,
            max: 30,
            divisions: 29,
            onChanged: (value) {
              setState(() {
                _tenureYears = value;
                _calculateEmi();
              });
            },
            textColor: textColor,
            activeColor: primaryColor,
          ),
          const SizedBox(height: 16),
          _SliderWithInput(
            label: '% Annual Interest Rate (%)',
            value: _annualRate,
            min: 1,
            max: 20,
            divisions: 190,
            onChanged: (value) {
              setState(() {
                _annualRate = value;
                _calculateEmi();
              });
            },
            textColor: textColor,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard({
    required Gradient cardGradient,
    required Color textColor,
    required Map<String, double> dataMap,
    required List<Color> colorList,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Text('Breakdown',
              style: TextStyle(
                  fontSize: 19, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 19),
          pie.PieChart(
            dataMap: dataMap,
            animationDuration: const Duration(milliseconds: 800),
            chartLegendSpacing: 24,
            chartRadius: MediaQuery.of(context).size.width / 2,
            colorList: colorList,
            chartType: pie.ChartType.ring,
            ringStrokeWidth: 35,
            legendOptions: const pie.LegendOptions(showLegends: false),
            chartValuesOptions: const pie.ChartValuesOptions(
              showChartValuesInPercentage: true,
              showChartValues: true,
              showChartValuesOutside: true,
            ),
          ),
          const SizedBox(height: 19),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend(
                  color: colorList[0], text: 'Principal', textColor: textColor),
              const SizedBox(width: 19),
              _buildChartLegend(
                  color: colorList[1], text: 'Interest', textColor: textColor),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLineChartCard(Gradient cardGradient, Color textColor,
      Color primaryColor, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: cardGradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Text(
            'Principal vs Interest',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 24),
          AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: _tenureYears > 10 ? 5 : 2,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          child: Text('Yr ${value.toInt()}',
                              style: TextStyle(fontSize: 10, color: textColor)),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _emiData
                        .map((e) => FlSpot(
                            e.year.toDouble(), e.balance / 100000)) // In Lakhs
                        .toList(),
                    isCurved: true,
                    color: primaryColor,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: _emiData
                        .map((e) => FlSpot(e.year.toDouble(),
                            e.interestPaid / 100000)) // In Lakhs
                        .toList(),
                    isCurved: true,
                    color: accentColor,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(
      {required Color color, required String text, required Color textColor}) {
    return Row(
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: textColor)),
      ],
    );
  }
}

class EmiDataPoint {
  final int year;
  final double principalPaid;
  final double interestPaid;
  final double balance;

  EmiDataPoint(
      {required this.year,
      required this.principalPaid,
      required this.interestPaid,
      required this.balance});
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
    // 🎯 MODIFIED: Allow parsing numbers with commas and currency symbols
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
    // 🎯 MODIFIED: Format numbers for better readability
    final formatter = NumberFormat.decimalPattern('en_IN');
    String text;
    if (widget.label.contains('Amount')) {
      text = '₹${formatter.format(value.round())}';
    } else if (widget.label.contains('%')) {
      text = '${value.toStringAsFixed(1)}%';
    } else {
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
    // 🎯 MODIFIED: Only update text if the field doesn't have focus
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
        Text(widget.label,
            style: TextStyle(
                color: widget.textColor.withOpacity(0.8), fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: widget.activeColor,
                  inactiveTrackColor: widget.activeColor.withOpacity(0.3),
                  thumbColor: widget.activeColor,
                  overlayColor: widget.activeColor.withOpacity(0.2),
                  valueIndicatorColor: widget.activeColor,
                  valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                ),
                child: Slider(
                  value: widget.value,
                  min: widget.min,
                  max: widget.max,
                  divisions: widget.divisions,
                  label: widget.value.round().toString(),
                  onChanged: widget.onChanged,
                ),
              ),
            ),
            // 🎯 MODIFIED: Increased width of the text field
            SizedBox(
              width: 120,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: TextStyle(color: widget.textColor, fontSize: 16),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: widget.activeColor.withOpacity(0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.activeColor, width: 2),
                  ),
                ),
                onSubmitted: _updateFromText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
