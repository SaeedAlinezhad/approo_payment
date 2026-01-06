import 'package:dio/dio.dart';
import 'package:approo_payment/src/data/models/product.dart';

abstract class ProductRemoteDataSource {
  Future<List<Product>> getProducts(String projectPackageName);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<Product>> getProducts(String projectPackageName) async {
    final response = await dio.get(
      '/package-names/$projectPackageName/products',
    );

    final List data = response.data;
    return data.map((e) => Product.fromJson(e)).toList();
  }
}