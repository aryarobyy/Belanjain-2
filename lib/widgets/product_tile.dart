import 'package:belanjain/models/product/product_model.dart';
import 'package:belanjain/services/product/product_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductTile extends StatelessWidget {
  final List<ProductModel> products;
  final Function(ProductModel)? onProductTap; // Add callback for product tap

  const ProductTile({
    super.key,
    required this.products,
    this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.decimalPattern('id');

    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 360;
    final isMedium = width >= 360 && width < 480;
    final crossAxisCount = width < 360 ? 1 : width < 480 ? 2 : 3;
    const spacing = 12.0;
    final itemWidth = (width - (spacing * (crossAxisCount + 1))) / crossAxisCount;
    final itemHeight = itemWidth * 1.2;
    final aspectRatio = itemWidth / itemHeight;

    return GridView.builder(
      padding: const EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return InkWell(
          onTap: () => onProductTap?.call(product), // Call the callback with the tapped product
          child: Card(
            color: Colors.grey[100],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      child: Image.network(
                        product.imageUrl,
                        height: isSmall
                            ? 80
                            : isMedium
                            ? 100
                            : 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: isSmall ? 12 : isMedium ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp.\ ${formatCurrency.format(product.price)}',
                    style: TextStyle(
                      fontSize: isSmall ? 12 : isMedium ? 13 : 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      FutureBuilder<double>(
                        future:
                        ProductService().getProductRating(product.productId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            );
                          } else if (snapshot.hasError) {
                            return const Text('-');
                          } else {
                            final val = snapshot.data ?? 0.0;
                            return Text(
                              val.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 14),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}