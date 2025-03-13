enum ProductCategory {
  electronics,
  clothing,
  beauty,
  home,
  sports,
  books,
  other,
}

extension ProductCategoryExtension on ProductCategory {
  String get value {
    switch (this) {
      case ProductCategory.electronics:
        return "electronics";
      case ProductCategory.clothing:
        return "clothing";
      case ProductCategory.beauty:
        return "beauty";
      case ProductCategory.home:
        return "home";
      case ProductCategory.sports:
        return "sports";
      case ProductCategory.books:
        return "books";
      default:
        return "other";
    }
  }

  static ProductCategory fromString(String category) {
    switch (category.toLowerCase()) {
      case "electronics":
        return ProductCategory.electronics;
      case "clothing":
        return ProductCategory.clothing;
      case "beauty":
        return ProductCategory.beauty;
      case "home":
        return ProductCategory.home;
      case "sports":
        return ProductCategory.sports;
      case "books":
        return ProductCategory.books;
      default:
        return ProductCategory.other;
    }
  }
}
