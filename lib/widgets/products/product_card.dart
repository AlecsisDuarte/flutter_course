import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import '../ui_elements/favorite_button.dart';
import '../ui_elements/width_spacing.dart';
import '../ui_elements/title_default.dart';

import 'price_tag.dart';
import 'address_tag.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/scoped_models/main_model.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int index;

  ProductCard(this.index, this.product);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: <Widget>[
        Hero(
          tag: product.id,
          child: FadeInImage(
            height: 300.0,
            fit: BoxFit.cover,
            image: NetworkImage(product.image),
            placeholder: AssetImage('assets/dummy_image.jpg'),
          ),
        ),
        Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Flexible(
                  flex: 6,
                  child: TitleDefault(product.title),
                ),
                Flexible(
                  child: WidthSpacing(),
                ),
                Flexible(
                  child: PriceTag(product.price.toString()),
                ),
              ],
            )),
        AddressTag(product.location?.address),
        _buildActionButtons(context, index),
      ],
    ));
  }

  Widget _buildActionButtons(BuildContext context, int index) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.info,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () => Navigator.pushNamed<bool>(context,
                                '/product/${model.displayProducts[index].id}')
                            .then((bool result) {
                          // if (result) deleteProducts(index);
                        })),
                FavoriteButton(index),
              ],
            )
          ],
        );
      },
    );
  }
}
