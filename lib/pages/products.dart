import 'package:flutter/material.dart';
import 'package:flutter_course/shared/adaptive_elevation.dart';
import 'package:flutter_course/widgets/ui_elements/logout_list_tile.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:flutter_course/widgets/products/products.dart';
import 'package:flutter_course/scoped_models/main_model.dart';
import '../widgets/ui_elements/page_loading.dart';

class ProductsPage extends StatefulWidget {
  final MainModel model;

  ProductsPage(this.model);

  @override
  State<StatefulWidget> createState() {
    return _ProductsPageState();
  }
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    widget.model.fetchProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            AppBar(
              elevation: getAdaptiveElevation(context),
              automaticallyImplyLeading: false,
              title: Text('Select'),
            ),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Manage Products'),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/admin');
              },
            ),
            LogoutListTile(),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('Products'),
        actions: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (BuildContext context, Widget child, MainModel model) {
              return IconButton(
                icon: Icon(model.displayFavoritesOnly
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: model.toggleDisplayMode,
              );
            },
          )
        ],
      ),
      body: _buildProductsList(),
    );
  }

  Widget _buildProductsList() {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return RefreshIndicator(
          child: model.isLoading ? PageLoading() : Products(),
          onRefresh: model.fetchProducts,
        );
      },
    );
  }

  // Widget _buildLoadingScreen() {
  //   return Container(
  //     alignment: Alignment.center,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       mainAxisSize: MainAxisSize.min,
  //       children: <Widget>[
  //         CircularProgressIndicator(),
  //         Text("Loading the munchies"),
  //       ],
  //     ),
  //   );
  // }
}
