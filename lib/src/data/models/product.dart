import 'package:approo_payment/src/domain/entities/product_entity.dart';

class Product extends ProductEntity {
  const Product({
    required super.id,
    required super.title,
    required super.price, required super.uuid,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        title: json['title'],
        price: json['price'],
        uuid: json['uuid'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'price': price,
        'uuid': uuid,
      };
}