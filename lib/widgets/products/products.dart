import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:flutter_course/scoped_models/main_model.dart';
import 'package:flutter_course/models/product.dart';
import 'product_card.dart';
import 'package:flutter_course/widgets/ui_elements/empty_list.dart';

class Products extends StatelessWidget {
  Products() {
    print('[Product Widget] Constructor');
  }

  @override
  Widget build(BuildContext context) {
    print('[Product Widget] build()');
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return _buildProductList(model.displayProducts);
      },
    );
  }

  Widget _buildProductList(List<Product> products) {
    Widget productCard;

    if (products.length > 0) {
      productCard = ListView.builder(
        itemBuilder: (BuildContext context, int index) =>
            ProductCard(index, products[index]),
        itemCount: products.length,
      );
    } else {
      productCard = EmptyList();
    }
    return productCard;
  }

  // Widget _buildEmptyListContainer() {
  //   return ListView(
  //     padding: EdgeInsets.all(20.0),
  //     shrinkWrap: true,
  //         children: <Widget>[
  //           Image.asset(
  //             'assets/silent_tears.gif',
  //             height: 100.0,
  //             width: 100.0,
  //           ),
  //           Text('No food found, add something', textAlign: TextAlign.center,),
  //         ],
  //       );
  // }
}
