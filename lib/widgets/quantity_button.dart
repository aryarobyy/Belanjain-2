import 'package:flutter/material.dart';

class QuantityButton extends StatefulWidget {
  final int initialAmount;
  final double price;
  final int stock;
  final ValueChanged<int> onChanged;

  const QuantityButton({
    Key? key,
    required this.initialAmount,
    required this.price,
    required this.stock,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<QuantityButton> createState() => _QuantityButtonState();
}

class _QuantityButtonState extends State<QuantityButton> {
  late int _amount;

  @override
  void initState() {
    super.initState();
    _amount = widget.initialAmount;
  }

  void _updateQuantity(int newAmount) {
    if (newAmount < 1 || newAmount > widget.stock) return;
    setState(() {
      _amount = newAmount;
    });
    widget.onChanged(_amount);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text("Jumlah: "),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            _updateQuantity(_amount - 1);
          },
          icon: const Icon(Icons.remove_circle_outline),
        ),
        Text('$_amount', style: const TextStyle(fontSize: 16)),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            _updateQuantity(_amount + 1);
          },
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}
