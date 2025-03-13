
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
  }) async {
      try{
        final String uuid = Uuid().v4();

        final data = {
          'product_id' : uuid,
          'category': category.value,
          'price': price,
          'stock': stock,
          'desc': desc
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
  }