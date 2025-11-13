import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:ui';
import 'package:intl/intl.dart';
import '../../../../theme/theme_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class MutualFundCalculatorScreen extends StatefulWidget {
  const MutualFundCalculatorScreen({super.key});

  @override
  State<MutualFundCalculatorScreen> createState() =>
      _MutualFundCalculatorScreenState();
}

class _MutualFundCalculatorScreenState
    extends State<MutualFundCalculatorScreen> {
  double _investmentAmount = 100000;
  double _expectedReturnRate = 12;
  double _investmentPeriod = 10;

  double _futureValue = 0;
  double _totalGains = 0;
  List<ChartDataPoint> _chartData = [];

  @override
  void initState() {
    super.initState();
    _calculateMutualFund();
  }

  // Helper for smart number formatting (Lakhs & Crores)
  String _formatLargeIndianNumber(double number) {
    if (number.abs() < 100000) {
      return '₹ ${NumberFormat.decimalPattern('en_IN').format(number.round())}';
    } else if (number.abs() < 10000000) {
      return '₹ ${(number / 100000).toStringAsFixed(2)}L';
    } else {
      return '₹ ${(number / 10000000).toStringAsFixed(2)}Cr';
    }
  }

  // 🎯 FIX: This function now dynamically calculates the interval to prevent labels from overlapping on long time periods.
  double _getBottomTitleInterval(double period) {
    if (period <= 12) return 2;
    if (period <= 20) return 5;
    return (period / 5).ceilToDouble();
  }

  void _calculateMutualFund() {
    final double p = _investmentAmount;
    final double annualRate = _expectedReturnRate;
    final int years = _investmentPeriod.toInt();

    if (p > 0 && annualRate > 0 && years > 0) {
      final double r = annualRate / 100;
      _futureValue = p * pow(1 + r, years);
      _totalGains = _futureValue - p;
      _generateChartData(p, r, years);
    } else {
      _futureValue = p;
      _totalGains = 0;
      _chartData = [];
    }
    setState(() {});
  }

  void _generateChartData(double principal, double annualRate, int totalYears) {
    List<ChartDataPoint> data = [];
    for (int year = 1; year <= totalYears; year++) {
      final value = principal * pow(1 + annualRate, year);
      data.add(ChartDataPoint(period: year, value: value));
    }
    _chartData = data;
  }

  void _resetCalculator() {
    setState(() {
      _investmentAmount = 100000;
      _expectedReturnRate = 12;
      _investmentPeriod = 10;
      _calculateMutualFund();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1E242A);

    final primaryColor =
        isDarkMode ? Colors.purpleAccent[100]! : Colors.purple.shade700;
    final gainsColor =
        isDarkMode ? Colors.greenAccent.shade400! : Colors.green.shade600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [const Color(0xFF4A148C), const Color(0xFF1A237E)]
                : [const Color(0xFFE0C3FC), const Color(0xFF8EC5FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(textColor),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: GlassmorphicContainer(
                    isDarkMode: isDarkMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInputSection(textColor, primaryColor),
                        const SizedBox(height: 32),
                        Divider(color: textColor.withOpacity(0.2)),
                        const SizedBox(height: 24),
                        Text('Projected Growth',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: textColor)),
                        const SizedBox(height: 16),
                        _ProjectionMeter(
                          investedAmount: _investmentAmount,
                          futureValue: _futureValue,
                          primaryColor: primaryColor,
                          textColor: textColor,
                        ),
                        const SizedBox(height: 24),
                        _buildResultsDisplay(
                            textColor, primaryColor, gainsColor),
                        const SizedBox(height: 32),
                        if (_chartData.isNotEmpty)
                          _buildBarChart(textColor, primaryColor),
                      ],
                    ),
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
          Text('Mutual Fund Calculator',
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold, fontSize: 22)),
        ],
      ),
    );
  }

  Widget _buildInputSection(Color textColor, Color primaryColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Investment Details',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
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
          label: 'Total Investment Amount',
          value: _investmentAmount,
          min: 1000,
          max: 10000000,
          divisions: 1000,
          onChanged: (value) {
            setState(() {
              _investmentAmount = value;
              _calculateMutualFund();
            });
          },
          textColor: textColor,
          activeColor: primaryColor,
        ),
        const SizedBox(height: 16),
        _SliderWithInput(
          label: 'Expected Return Rate (% p.a.)',
          value: _expectedReturnRate,
          min: 1,
          max: 30,
          divisions: 290,
          onChanged: (value) {
            setState(() {
              _expectedReturnRate = value;
              _calculateMutualFund();
            });
          },
          textColor: textColor,
          activeColor: primaryColor,
        ),
        const SizedBox(height: 16),
        _SliderWithInput(
          label: 'Investment Period (Years)',
          value: _investmentPeriod,
          min: 1,
          max: 40,
          divisions: 39,
          onChanged: (value) {
            setState(() {
              _investmentPeriod = value;
              _calculateMutualFund();
            });
          },
          textColor: textColor,
          activeColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildResultsDisplay(
      Color textColor, Color primaryColor, Color gainsColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _ResultItem(
            label: 'Invested',
            value: _formatLargeIndianNumber(_investmentAmount),
            color: textColor),
        _ResultItem(
            label: 'Gains',
            value: _formatLargeIndianNumber(_totalGains),
            color: gainsColor),
        _ResultItem(
            label: 'Future Value',
            value: _formatLargeIndianNumber(_futureValue),
            color: primaryColor),
      ],
    );
  }

  Widget _buildBarChart(Color textColor, Color primaryColor) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final tooltipColor = isDarkMode ? Colors.black : Colors.blueGrey;
    final tooltipTextColor = isDarkMode ? Colors.white : Colors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Yearly Growth',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => tooltipColor,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final formattedValue = NumberFormat.currency(
                      locale: 'en_IN',
                      symbol: '₹ ',
                      decimalDigits: 2,
                    ).format(rod.toY);
                    return BarTooltipItem(
                      'Year ${group.x.toInt()}\n',
                      TextStyle(
                        color: tooltipTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: formattedValue,
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              alignment: BarChartAlignment.spaceAround,
              titlesData: FlTitlesData(
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: _getBottomTitleInterval(_investmentPeriod),
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text('Yr ${value.toInt()}',
                            style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 10)),
                      );
                    },
                    reservedSize: 24,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              barGroups: _chartData
                  .map(
                    (data) => BarChartGroupData(
                      x: data.period.toInt(),
                      barRods: [
                        BarChartRodData(
                          toY: data.value,
                          gradient: LinearGradient(
                            colors: [
                              primaryColor.withOpacity(0.6),
                              primaryColor
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 15,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        )
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _ResultItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withOpacity(0.7),
                  fontSize: 14)),
          const SizedBox(height: 4),
          FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _ProjectionMeter extends StatefulWidget {
  final double investedAmount;
  final double futureValue;
  final Color primaryColor;
  final Color textColor;

  const _ProjectionMeter({
    required this.investedAmount,
    required this.futureValue,
    required this.primaryColor,
    required this.textColor,
  });

  @override
  _ProjectionMeterState createState() => _ProjectionMeterState();
}

class _ProjectionMeterState extends State<_ProjectionMeter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Tween<double> _tween;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _tween = Tween<double>(begin: 0.0, end: _calculateEndValue());
    _animation = _tween
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _ProjectionMeter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.futureValue != oldWidget.futureValue ||
        widget.investedAmount != oldWidget.investedAmount) {
      _tween.begin = _animation.value;
      _tween.end = _calculateEndValue();
      _controller.forward(from: 0.0);
    }
  }

  double _calculateEndValue() {
    const maxGrowth = 50.0; // The meter will be full at 50x growth
    double growthMultiple = widget.investedAmount > 0
        ? widget.futureValue / widget.investedAmount
        : 1.0;
    return (growthMultiple / maxGrowth).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _MeterPainter(
              value: _animation.value,
              primaryColor: widget.primaryColor,
              textColor: widget.textColor,
            ),
          );
        },
      ),
    );
  }
}

class _MeterPainter extends CustomPainter {
  final double value; // 0.0 to 1.0
  final Color primaryColor;
  final Color textColor;
  _MeterPainter(
      {required this.value,
      required this.primaryColor,
      required this.textColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2.2;
    const startAngle = -pi;
    const sweepAngle = pi;

    final backgroundPaint = Paint()
      ..color = textColor.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    final foregroundPaint = Paint()
      ..shader = SweepGradient(
        colors: [primaryColor.withOpacity(0.5), primaryColor],
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 20;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        sweepAngle, false, backgroundPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        sweepAngle * value, false, foregroundPaint);

    final needleAngle = startAngle + sweepAngle * value;
    final needlePaint = Paint()
      ..color = textColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final needleEnd = center +
        Offset(
            cos(needleAngle) * (radius - 5), sin(needleAngle) * (radius - 5));
    final needleStart =
        center + Offset(cos(needleAngle) * 20, sin(needleAngle) * 20);

    canvas.drawLine(needleStart, needleEnd, needlePaint);
    canvas.drawCircle(center, 15, Paint()..color = textColor);
    canvas.drawCircle(center, 10, Paint()..color = primaryColor);
  }

  @override
  bool shouldRepaint(covariant _MeterPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}

class ChartDataPoint {
  final int period;
  final double value;
  ChartDataPoint({required this.period, required this.value});
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
