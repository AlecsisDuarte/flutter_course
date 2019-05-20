import 'package:flutter/material.dart';

import 'package:flutter_course/pages/product_edit.dart';
import 'package:flutter_course/pages/product_list.dart';
import 'package:flutter_course/scoped_models/main_model.dart';
import 'package:flutter_course/shared/adaptive_elevation.dart';
import 'package:flutter_course/widgets/ui_elements/logout_list_tile.dart';

class ProductsAdminPage extends StatelessWidget {
  final MainModel model;

  ProductsAdminPage(this.model);

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            drawer: Drawer(
              child: Column(
                children: <Widget>[
                  AppBar(
                    elevation: getAdaptiveElevation(context),
                    automaticallyImplyLeading: false,
                    title: Text('Select'),
                  ),
                  ListTile(
                    leading: Icon(Icons.shopping_basket),
                    title: Text('List Products'),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                  ),
                  LogoutListTile(),
                ],
              ),
            ),
            appBar: AppBar(
              title: Text('Manage Products'),
              bottom: TabBar(
                tabs: <Widget>[
                  Tab(
                    icon: isPortrait ? Icon(Icons.create) : null,
                    text: 'Create Product',
                  ),
                  Tab(
                    icon: isPortrait ? Icon(Icons.list) : null,
                    text: 'My Products',
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: <Widget>[ProductEditPage(), ProductListPage(model)],
            )));
  }
}
