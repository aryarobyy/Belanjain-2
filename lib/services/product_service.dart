
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
      String? rating,
      String? status
  }) async {
      try{
        final String uuid = Uuid().v4();

        final data = {
          'title': title,
          'product_id' : uuid,
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
  }