import 'package:flutter/material.dart';
import '../detail_screen.dart';
import '../../providers/product_provider.dart';

part 'accessoris_category.dart';
part 'all_category.dart';
part 'electronic_category.dart';
part 'footware_category.dart';

class Products extends StatelessWidget {
  final ProductProvider productProvider;
  final List<dynamic> filteredProducts;
  final String currentCategory;

  const Products({
    Key? key,
    required this.productProvider,
    required this.filteredProducts,
    required this.currentCategory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (currentCategory) {
      case 'Accessories':
        return AccessoriesCategory(filteredProducts: filteredProducts);
      case 'Electronics':
        return ElectronicCategory(filteredProducts: filteredProducts);
      case 'Footwear':
        return FootwearCategory(filteredProducts: filteredProducts);
      default:
        return AllCategory(filteredProducts: filteredProducts);
    }
  }
}
