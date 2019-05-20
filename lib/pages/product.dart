import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_course/shared/adaptive_elevation.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_course/models/location_data.dart';
import 'package:flutter_course/models/product.dart';
import 'package:flutter_course/widgets/products/product_fab.dart';
import 'package:flutter_course/widgets/ui_elements/width_spacing.dart';

import 'package:flutter_course/widgets/ui_elements/favorite_button.dart';
import 'package:flutter_course/scoped_models/main_model.dart';

class ProductPage extends StatelessWidget {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return WillPopScope(
          onWillPop: () {
            model.selectProduct(null);
            Navigator.pop(context, false);
            return Future.value(false);
          },
          child: sliverPage(context, model));
    });
  }

  Widget sliverPage(BuildContext context, MainModel model) {
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color accentColor = Theme.of(context).accentColor;

    Product product = model.selectedProduct;
    final int index = model.displayProducts.indexOf(product);
    return Stack(
      alignment: AlignmentDirectional.bottomEnd,
      children: <Widget>[
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: CustomScrollView(
            slivers: <Widget>[
              _buildTitleSliver(context, product.title, product.price,
                  product.image, index, product.id),
              SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  _buildAddressContainer(
                      product.location, context, primaryColor, accentColor),
                  _buildDescriptionContainer(
                      product.description, context, primaryColor, accentColor)
                ]),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.all(18.0),
          child: ProductFAB(product),
        ),
      ],
    );
  }

  Widget _buildTitleSliver(BuildContext context, String title, double price,
      String image, int productIndex, String productId) {
    return SliverAppBar(
      elevation: getAdaptiveElevation(context),
      pinned: true,
      expandedHeight: 400,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Hero(
              tag: productId,
              child: FadeInImage(
                height: 350.0,
                fit: BoxFit.cover,
                image: NetworkImage(image),
                placeholder: AssetImage('assets/dummy_image.jpg'),
              ),
            ),
            Container(
              height: 400.0,
              decoration: BoxDecoration(
                  color: Colors.white,
                  gradient: LinearGradient(
                      begin: FractionalOffset.topCenter,
                      end: FractionalOffset.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: [
                        0.0,
                        0.7,
                        1.0
                      ])),
            ),
          ],
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // SizedBox(),
            Flexible(
              child: _buildTitle(title, context),
              flex: 2,
            ),
            Flexible(
              child: SizedBox(
                width: 8.0,
              ),
            ),
            Flexible(
              child: Container(
                child: Text(
                  "\$${price.toString()}",
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).primaryTextTheme.title.color),
                ),
                padding: EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(5.0)),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FavoriteButton(
          productIndex,
          unselectAutomatically: false,
        )
      ],
    );
  }

  Widget _buildTitle(String title, BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Text(
      title,
      textAlign: TextAlign.center,
      softWrap: false,
      overflow: TextOverflow.fade,
      style: TextStyle(
        fontSize: deviceWidth > 400 ? 26.0 : 14.0,
        fontWeight: FontWeight.bold,
        fontFamily: 'BioRhyme',
      ),
    );
  }

  Widget _buildAddressContainer(LocationData locData, BuildContext context,
      Color primaryColor, Color accentColor) {
    return GestureDetector(
      onTap: () => _showMap(locData, context),
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.location_on,
              color: primaryColor,
            ),
            WidthSpacing(),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                locData?.address,
                softWrap: true,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Roboto',
                    fontSize: 16,
                    color: Colors.black,
                    decoration: TextDecoration.none),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionContainer(String description, BuildContext context,
      Color primaryColor, Color accentColor) {
    return Container(
        padding: EdgeInsets.all(10.0),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.description,
              color: primaryColor,
            ),
            WidthSpacing(),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                description,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                    color: Colors.black,
                    decoration: TextDecoration.none),
              ),
            ),
          ],
        ));
  }

  void _showMap(LocationData locData, BuildContext context) {
    final LatLng location = LatLng(locData.latitude, locData.longitude);
    final CameraPosition cameraPosition =
        CameraPosition(target: location, zoom: 15);
    final Marker marker = Marker(
      markerId: MarkerId(location.toString()),
      position: location,
      infoWindow: InfoWindow(title: 'Position'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
    );

    final Set<Marker> markers = Set<Marker>();
    markers.clear();
    markers.add(marker);

    final GoogleMap map = GoogleMap(
      initialCameraPosition: cameraPosition,
      onMapCreated: (GoogleMapController controller) {
        if (!_controller.isCompleted) {
          _controller.complete(controller);
        }
      },
      markers: markers,
    );

    final IconButton closeButton = IconButton(
      icon: Icon(Icons.close),
      color: Colors.redAccent,
      onPressed: () => Navigator.of(context).pop(),
      alignment: Alignment.topRight,
    );

    final Stack stack = Stack(
      alignment: Alignment.topRight,
      children: <Widget>[map, closeButton],
    );

    final Container container = Container(
      child: stack,
      padding: EdgeInsets.symmetric(vertical: 12),
      height: 500,
      width: 400,
    );

    Dialog mapDialog = Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: container,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => mapDialog,
    );
  }
}
