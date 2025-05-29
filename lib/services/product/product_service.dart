
  import 'package:belanjain/models/product/category.dart';
  import 'package:belanjain/models/product/product_model.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:uuid/uuid.dart';

  final PRODUCT_COLLECTION = 'products';

  class ProductService {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    Future<ProductModel> postProduct ({
      required String title,
      required ProductCategory category,
      required double price,
      required double stock,
      required String desc,
      required String imageUrl,
      required String sellerId,
      String? rating,
      String? status
  }) async {
      try{
        final String uuid = Uuid().v4();

        final data = {
          'id' : uuid,
          'title': title,
          'sellerId': sellerId,
          'category': category.value,
          'price': price,
          'stock': stock,
          'desc': desc,
          'image': imageUrl,
          'rating': rating,
          'status': status,
        };

        await _firestore.collection(PRODUCT_COLLECTION).doc(uuid).set(data);
        final storedData = await _firestore.collection(PRODUCT_COLLECTION).doc(uuid).get();
        if(!storedData.exists){
          throw Exception("error");
        }
        return ProductModel.fromMap(storedData.data()!);
      } catch (e) {
        throw Exception("Error post product $e");
      }
    }

    Future <List<ProductModel>> getProducts() async {
      try{
        final res = await _firestore
            .collection(PRODUCT_COLLECTION)
            .get();

        List<ProductModel> products = res.docs.map((doc) {
          return ProductModel.fromMap(doc.data());
        }).toList();

        return products;
      } catch (e) {
        throw Exception("Error post product $e");
      }
    }

    Future<ProductModel> getProductById(String productId) async {
      final docSnapshot = await _firestore
          .collection(PRODUCT_COLLECTION)
          .doc(productId)
          .get();

      final data = docSnapshot.data();
      if (data == null) {
        throw Exception("Product not found");
      }
      return ProductModel.fromMap(data);
    }

    Future<List<ProductModel>> getProductBySellerId(String sellerId) async {
      final querySnapshot = await _firestore
          .collection(PRODUCT_COLLECTION)
          .where('sellerId', isEqualTo: sellerId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("No products found for seller $sellerId");
      }

      final products = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel.fromMap(data);
      }).toList();

      return products;
    }


    Future<ProductModel> updateProduct(Map<String, dynamic> updatedData, String productId) async {
      try {
        await _firestore
            .collection(PRODUCT_COLLECTION)
            .doc(productId)
            .set(updatedData);

        final DocumentSnapshot productDoc =
        await _firestore.collection(PRODUCT_COLLECTION).doc(productId).get();

        if (productDoc.exists) {
          print("Fetched updated user data: ${productDoc.data()}");
          return ProductModel.fromMap(productDoc.data() as Map<String, dynamic>);
        } else {
          print("User document not found after update.");
          throw Exception("Failed to retrieve updated user data");
        }
      } catch (e) {
        throw Exception(e);
      }
    }

    Future<double> getProductRating(String productId) async {
      final querySnapshot = await _firestore
          .collection(PRODUCT_COLLECTION)
          .doc(productId)
          .collection("comments")
          .where('rating', isGreaterThan: 0)
          .get();

      final ratings = querySnapshot.docs
          .map((doc) => doc['rating'])
          .whereType<num>()
          .toList();

      if (ratings.isEmpty) return 0.0;

      final total = ratings.fold<double>(0.0, (sum, rating) => sum + rating);
      return double.parse((total / ratings.length).toStringAsFixed(1));
    }

    Future<List<ProductModel>> getProductsByName(String nameProduct) async {
      if (nameProduct.isEmpty) {
        return getProducts();
      }

      final searchQuery = nameProduct.toLowerCase();

      final querySnapshot = await _firestore
          .collection(PRODUCT_COLLECTION)
          .where('searchKeywords', arrayContains: searchQuery)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          return ProductModel.fromMap(data);
        }).toList();
      }

      return _getProductsByPrefix(searchQuery);
    }

    Future<List<ProductModel>> _getProductsByPrefix(String prefix) async {
      final querySnapshot = await _firestore
          .collection(PRODUCT_COLLECTION)
          .where('titleLowercase', isGreaterThanOrEqualTo: prefix)
          .where('titleLowercase', isLessThanOrEqualTo: prefix + '\uf8ff')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel.fromMap(data);
      }).toList();
    }

    List<String> generateSearchKeywords(String title) {
      final keywords = <String>{};
      final words = title.toLowerCase().split(' ');

      for (final word in words) {
        // Add the full word
        keywords.add(word);

        for (int i = 1; i <= word.length; i++) {
          keywords.add(word.substring(0, i));
        }
      }

      return keywords.toList();
    }

    Future<void> saveProductWithSearchKeywords(ProductModel product) async {
      final searchKeywords = generateSearchKeywords(product.title);

      final productData = product.toJson();
      productData['searchKeywords'] = searchKeywords;
      productData['titleLowercase'] = product.title.toLowerCase();

      await _firestore
          .collection(PRODUCT_COLLECTION)
          .doc(product.productId)
          .set(productData);
    }
  }