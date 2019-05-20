import 'package:flutter/material.dart';
import 'package:flutter_course/models/product.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:flutter_course/scoped_models/main_model.dart';

class FavoriteButton extends StatelessWidget {
  final int productIndex;
  final bool unselectAutomatically;

  FavoriteButton(this.productIndex, {this.unselectAutomatically = true});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      final bool isFavorite = model.displayProducts[productIndex].isFavorite;
      return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.red,
          ),
          onPressed: () {
            if (productIndex == null) {
              return;
            }
            Product product = model.displayProducts[productIndex];
            model.selectProduct(product.id);
            model.toggleproductFavoriteStatus();
            if (unselectAutomatically) {
              model.selectProduct(null);
            }
          });
    });
  }
}
