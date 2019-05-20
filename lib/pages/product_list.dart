import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:flutter_course/widgets/ui_elements/empty_list.dart';
import 'package:flutter_course/widgets/ui_elements/page_loading.dart';
import 'package:flutter_course/pages/product_edit.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/scoped_models/main_model.dart';

class ProductListPage extends StatefulWidget {
  final MainModel model;

  ProductListPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return ProductListState();
  }
}

class ProductListState extends State<ProductListPage> {
  @override
  void initState() {
    widget.model.fetchProducts(onlyForUser: true, clearProducts: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      if (model.isLoading) {
        return PageLoading(message: 'Loading your products');
      } else if (model.allProducts.length > 0) {
        return _buildProductsList(model);
      } else {
        return EmptyList(
          message: 'You haven\'t added any product',
        );
      }
    });
  }

  Widget _buildEditButton(BuildContext context, int index, MainModel model) {
    return IconButton(
      icon: Icon(Icons.edit),
      onPressed: () {
        Product product = model.allProducts[index];
        model.selectProduct(product.id);
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (BuildContext context) => ProductEditPage(),
              ),
            )
            .then((_) => model.selectProduct(null));
      },
    );
  }

  Widget _buildProductsList(MainModel model) => ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          Product product = model.allProducts[index];
          return Dismissible(
            key: Key(product.title),
            onDismissed: (DismissDirection dismissDirection) {
              if (dismissDirection == DismissDirection.endToStart) {
                model.selectProduct(product.id);
                model.deleteProduct();
              } else if (dismissDirection == DismissDirection.startToEnd) {
                print('Swiped from start to end');
              }
            },
            background: Container(
              color: Colors.red,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: <Widget>[
                  Spacer(),
                  Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      product.image,
                    ),
                  ),
                  title: Text(product.title),
                  subtitle: Text('\$${product.price.toString()}'),
                  trailing: _buildEditButton(context, index, model),
                ),
                Divider()
              ],
            ),
          );
        },
        itemCount: model.allProducts.length,
      );
}
