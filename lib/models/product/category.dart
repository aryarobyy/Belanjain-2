enum ProductCategory {
  all,
  electronics,
  fashion,
  book,
  furnitures,
  sports,
  books,
  other,
}

extension ProductCategoryExtension on ProductCategory {
  String get value {
    switch (this) {
      case ProductCategory.all:
        return "all";
      case ProductCategory.electronics:
        return "electronics";
      case ProductCategory.fashion:
        return "fashion";
      case ProductCategory.book:
        return "book";
      case ProductCategory.furnitures:
        return "furnitures";
      case ProductCategory.sports:
        return "sports";
      default:
        return "other";
    }
  }

  static ProductCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case "all":
        return ProductCategory.all;
      case "electronics":
        return ProductCategory.electronics;
      case "fashion":
        return ProductCategory.fashion;
      case "book":
        return ProductCategory.book;
      case "furnitures":
        return ProductCategory.furnitures;
      case "sports":
        return ProductCategory.sports;
      default:
        return ProductCategory.other;
    }
  }
}
