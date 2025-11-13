import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../../../theme/theme_provider.dart';

class InflationCalculatorScreen extends StatefulWidget {
  const InflationCalculatorScreen({super.key});

  @override
  State<InflationCalculatorScreen> createState() =>
      _InflationCalculatorScreenState();
}

class _InflationCalculatorScreenState extends State<InflationCalculatorScreen> {
  double _presentValue = 100000;
  double _inflationRate = 6;
  double _timePeriod = 10;

  double _futureValue = 0;

  @override
  void initState() {
    super.initState();
    _calculateInflation();
  }

  void _calculateInflation() {
    final double p = _presentValue;
    final double annualRate = _inflationRate;
    final int years = _timePeriod.toInt();

    if (p > 0 && annualRate > 0 && years > 0) {
      final double r = annualRate / 100; // Annual inflation rate
      _futureValue = p * pow(1 + r, years);
    } else {
      if (p > 0) {
        _futureValue = p;
      } else {
        _futureValue = 0;
      }
    }
    setState(() {});
  }

  void _resetCalculator() {
    setState(() {
      _presentValue = 100000;
      _inflationRate = 6;
      _timePeriod = 10;
      _calculateInflation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final primaryColor =
        isDarkMode ? Colors.tealAccent.shade400 : Colors.teal.shade700;

    final cardGradient = isDarkMode
        ? LinearGradient(
            colors: [const Color(0xFF2A3A3A), const Color(0xFF1E2B2B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight)
        : const LinearGradient(
            colors: [Color(0xFFF0FAF8), Color(0xFFE6F4F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
                  colors: [
                    Color(0xFF29323c),
                    Color(0xFF485563),
                    Color(0xFF2b5876)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    Color(0xFFfbc2eb),
                    Color(0xFFa6c1ee),
                    Color(0xFFf5ea75)
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
                    Text('Inflation Calculator',
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
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: cardGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Purchasing Power',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'See how the value of your money could change over time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14, color: textColor.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 24),
                        _PurchasingPowerVisualizer(
                            presentValue: _presentValue,
                            futureValue: _futureValue,
                            years: _timePeriod,
                            primaryColor: primaryColor),
                        const SizedBox(height: 24),
                        Divider(color: textColor.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        _buildInputSection(textColor, primaryColor),
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

  Widget _buildInputSection(Color textColor, Color primaryColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Adjust Values',
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
          label: 'Present Amount (₹)',
          value: _presentValue,
          min: 1000,
          max: 10000000,
          divisions: 1000,
          onChanged: (value) {
            setState(() {
              _presentValue = value;
              _calculateInflation();
            });
          },
          textColor: textColor,
          activeColor: primaryColor,
        ),
        const SizedBox(height: 16),
        _SliderWithInput(
          label: 'Annual Inflation Rate (%)',
          value: _inflationRate,
          min: 1,
          max: 20,
          divisions: 190,
          onChanged: (value) {
            setState(() {
              _inflationRate = value;
              _calculateInflation();
            });
          },
          textColor: textColor,
          activeColor: primaryColor,
        ),
        const SizedBox(height: 16),
        _SliderWithInput(
          label: 'Time Period (Years)',
          value: _timePeriod,
          min: 1,
          max: 50,
          divisions: 49,
          onChanged: (value) {
            setState(() {
              _timePeriod = value;
              _calculateInflation();
            });
          },
          textColor: textColor,
          activeColor: primaryColor,
        ),
      ],
    );
  }
}

class _PurchasingPowerVisualizer extends StatefulWidget {
  final double presentValue;
  final double futureValue;
  final double years;
  final Color primaryColor;

  const _PurchasingPowerVisualizer(
      {required this.presentValue,
      required this.futureValue,
      required this.years,
      required this.primaryColor});

  @override
  State<_PurchasingPowerVisualizer> createState() =>
      _PurchasingPowerVisualizerState();
}

class _PurchasingPowerVisualizerState extends State<_PurchasingPowerVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _PurchasingPowerVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.futureValue != oldWidget.futureValue ||
        widget.presentValue != oldWidget.presentValue) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    final purchasingPowerRatio =
        (widget.futureValue > 0 && widget.presentValue > 0)
            ? widget.presentValue / widget.futureValue
            : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Today's Basket
            Column(
              children: [
                Text('Today',
                    style: TextStyle(color: textColor.withOpacity(0.7))),
                Text('₹ ${widget.presentValue.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 8),
                _ShoppingBasket(
                    powerRatio: 1.0,
                    color: widget.primaryColor.withOpacity(0.5)),
              ],
            ),
            // Arrow
            Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Icon(Icons.arrow_forward_rounded,
                  size: 24, color: textColor.withOpacity(0.5)),
            ),
            // Future Basket
            Column(
              children: [
                Text('In ${widget.years.toInt()} Years',
                    style: TextStyle(color: textColor.withOpacity(0.7))),
                Text('₹ ${widget.presentValue.toStringAsFixed(0)}',
                    style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return _ShoppingBasket(
                      powerRatio:
                          Tween<double>(begin: 0.0, end: purchasingPowerRatio)
                              .animate(_controller)
                              .value,
                      color: widget.primaryColor,
                    );
                  },
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'In ${widget.years.toInt()} years, you would need ₹ ${widget.futureValue.toStringAsFixed(0)} to have the same purchasing power as ₹ ${widget.presentValue.toStringAsFixed(0)} today.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.8)),
        )
      ],
    );
  }
}

class _ShoppingBasket extends StatelessWidget {
  final double powerRatio; // 0.0 to 1.0
  final Color color;
  const _ShoppingBasket({required this.powerRatio, required this.color});

  @override
  Widget build(BuildContext context) {
    final List<IconData> items = [
      Icons.shopping_cart,
      Icons.apple,
      Icons.bakery_dining,
      Icons.icecream,
      Icons.local_gas_station,
      Icons.home,
      Icons.car_rental,
      Icons.phone_android,
      Icons.tv
    ];
    final int itemsToShow = (items.length * powerRatio).round();

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3))),
      child: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemCount: items.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: index < itemsToShow ? 1.0 : 0.1,
            child: Icon(items[index], color: color, size: 20),
          );
        },
      ),
    );
  }
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
    double? newValue = double.tryParse(text);
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
    String text = value.toStringAsFixed(1);
    if (value == value.roundToDouble()) {
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
    if (widget.value != oldWidget.value) {
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
                  label: widget.value.toStringAsFixed(1),
                  onChanged: widget.onChanged,
                ),
              ),
            ),
            SizedBox(
              width: 90,
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
