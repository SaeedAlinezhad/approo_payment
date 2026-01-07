import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int id;
  final String title;
  final int price;
  final String? uuid;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.uuid,
  });

  @override
  List<Object?> get props => [id, title, price,uuid];
}
