import 'package:belanjain/components/colors.dart';
import 'package:flutter/material.dart';

class VolumeSelector extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onChanged;
  final int starCount;
  final bool allowHalfStars;


  const VolumeSelector({
    Key? key,
    this.initialValue = 2.5,
    required this.onChanged,
    this.starCount = 5,
    this.allowHalfStars = true,
  }) : super(key: key);

  @override
  _VolumeSelectorState createState() => _VolumeSelectorState();
}

class _VolumeSelectorState extends State<VolumeSelector> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue.clamp(0.0, widget.starCount.toDouble());
  }

  void _updateValue(double newValue) {
    setState(() => _currentValue = newValue);
    widget.onChanged(_currentValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.starCount, (index) {
            double starValue = index + 1.0;
            IconData icon;
            if (_currentValue >= starValue) {
              icon = Icons.star;
            } else if (widget.allowHalfStars && _currentValue >= starValue - 0.5) {
              icon = Icons.star_half;
            } else {
              icon = Icons.star_border;
            }
            return GestureDetector(
              onTap: () {
                _updateValue(starValue);
              },
              child: Icon(
                icon,
                size: 32,
                color: goldColor,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _currentValue,
          min: 0.0,
          max: widget.starCount.toDouble(),
          divisions: widget.allowHalfStars ? (widget.starCount * 2) : widget.starCount,
          label: _currentValue.toStringAsFixed(widget.allowHalfStars ? 1 : 0),
          onChanged: (value) => _updateValue(value),
        ),
      ],
    );
  }
}