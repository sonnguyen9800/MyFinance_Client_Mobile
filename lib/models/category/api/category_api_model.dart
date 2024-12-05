import 'package:json_annotation/json_annotation.dart';
part 'category_api_model.g.dart';

/// A model class representing the request payload for creating or updating an expense category.
///
/// This class is used in API requests to:
/// * Create a new expense category
/// * Update an existing expense category
///
/// Example usage:
/// ```dart
/// final request = CategoryUpdateRequest(
///   name: 'Groceries',
///   color: '#FF5733',
///   iconName: 'shopping_cart',
/// );
/// ```
@JsonSerializable()
class CategoryUpdateRequest {
  /// The name of the category.
  ///
  /// Must be unique and non-empty.
  /// Example: 'Groceries', 'Transportation', 'Entertainment'
  @JsonKey(name: 'name')
  final String name;

  /// The color of the category in hexadecimal format.
  ///
  /// Must be a valid hex color code starting with '#'.
  /// Example: '#FF5733', '#33FF57', '#5733FF'
  @JsonKey(name: 'color')
  final String color;

  /// The name of the icon to be used for this category.
  ///
  /// Must be a valid icon name from the Material Icons set.
  /// Example: 'shopping_cart', 'directions_car', 'movie'
  @JsonKey(name: 'icon_name')
  final String iconName;

  /// Creates a new [CategoryUpdateRequest] instance.
  ///
  /// All parameters are required and must be non-null:
  /// * [name]: The name of the category
  /// * [color]: The color in hex format (e.g., '#FF5733')
  /// * [iconName]: The name of the Material Icon
  CategoryUpdateRequest({
    required this.name,
    required this.color,
    required this.iconName,
  });

  /// Creates a [CategoryUpdateRequest] instance from a JSON map.
  factory CategoryUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$CategoryUpdateRequestFromJson(json);

  /// Converts this [CategoryUpdateRequest] instance to a JSON map.
  Map<String, dynamic> toJson() => _$CategoryUpdateRequestToJson(this);
}
