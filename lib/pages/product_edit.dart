import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course/shared/adaptive_elevation.dart';
import 'package:flutter_course/widgets/form_inputs/image.dart';
import 'package:flutter_course/widgets/ui_elements/adaptive_progress_indicator.dart';
import 'package:scoped_model/scoped_model.dart';

import '../widgets/ui_elements/height_spacing.dart';
import '../widgets/helpers/ensure_visible_when_focused.dart';
import 'package:flutter_course/models/product.dart';
import '../scoped_models/main_model.dart';
import '../widgets/form_inputs/location.dart';
import '../models/location_data.dart';

class ProductEditPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProductEditPageState();
  }
}

class _ProductEditPageState extends State<ProductEditPage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': 0,
    'image': null,
    'location': null,
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _priceFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  final _titleTextController = TextEditingController();
  final _descriptionTextController = TextEditingController();
  final _priceTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      final Widget pageContent =
          _buildPageContent(context, model.selectedProduct);
      return model.selectedProductId == null
          ? pageContent
          : Scaffold(
              appBar: AppBar(
                elevation: getAdaptiveElevation(context),
                title: Text("Edit Product"),
              ),
              body: pageContent);
    });
  }

  void emptyFieldDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text('ACEPT'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Widget _buildTitleTextField(Product product) {
    final String titleText = _titleTextController.text.trim();
    if (product == null && titleText.isEmpty) {
      _titleTextController.text = '';
    } else if (product != null && titleText.isEmpty) {
      _titleTextController.text = product.title;
    }
    return EnsureVisibleWhenFocused(
      focusNode: _titleFocusNode,
      child: TextFormField(
        focusNode: _titleFocusNode,
        decoration: InputDecoration(labelText: "Product Title"),
        keyboardType: TextInputType.text,
        textCapitalization: TextCapitalization.words,
        controller: _titleTextController,
        validator: (String value) {
          if (value.isEmpty) {
            return "Title is required";
          } else if (value.length < 5) {
            return 'Title should be 5+ character long';
          }
          return null;
        },
        onSaved: (String value) => _formData['title'] = value,
      ),
    );
  }

  Widget _buildDescriptionTextField(Product product) {
    final String descriptionText = _descriptionTextController.text.trim();
    if (product == null && descriptionText.isEmpty) {
      _descriptionTextController.text = '';
    } else if (product != null && descriptionText.isEmpty) {
      _descriptionTextController.text = product.description;
    }
    return EnsureVisibleWhenFocused(
      focusNode: _descriptionFocusNode,
      child: TextFormField(
        focusNode: _descriptionFocusNode,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: "Product Description",
          hintText: "Describe this tasty product",
          // prefixIcon: Icon(Icons.),
        ),
        keyboardType: TextInputType.multiline,
        controller: _descriptionTextController,
        textCapitalization: TextCapitalization.sentences,
        validator: (String value) {
          if (value.isEmpty) {
            return "Description is required";
          } else if (value.length < 10) {
            return 'Description should be 10+ character long';
          }
          return null;
        },
        onSaved: (String value) => _formData['description'] = value,
      ),
    );
  }

  Widget _buildPriceTextField(Product product) {
    final String priceText = _priceTextController.text.trim();
    if (product == null && priceText.isEmpty) {
      _priceTextController.text = '';
    } else if (product != null && priceText.isEmpty) {
      _priceTextController.text = product.price.toString();
    }
    return EnsureVisibleWhenFocused(
      focusNode: _priceFocusNode,
      child: TextFormField(
        focusNode: _priceFocusNode,
        decoration: InputDecoration(
          labelText: "Product Price",
          hintText: '0.00',
          // prefixIcon: Icon(Icons.attach_money),
        ),
        keyboardType: TextInputType.number,
        controller: _priceTextController,
        validator: (String value) {
          if (value.isEmpty) {
            return 'Price required';
          }
          value = value.replaceFirst(",", ".");
          if (double.tryParse(value) == null) {
            return 'Price must be a number';
          }
          return null;
        },
        onSaved: (String value) =>
            _formData['price'] = double.parse(value.replaceFirst(',', '.')),
      ),
    );
  }

  Widget _buildPageContent(BuildContext context, Product product) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 760.0 ? 700.0 : deviceWidth * 0.95;
    final double targetPadding = deviceWidth - targetWidth;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: targetPadding),
            children: <Widget>[
              _buildTitleTextField(product),
              _buildDescriptionTextField(product),
              _buildPriceTextField(product),
              LocationInput(_setLocation, product),
              HeightSpacing(),
              ImageInput(_setImage, product),
              HeightSpacing(),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Container(
        padding: EdgeInsets.only(bottom: 8.0),
        child: model.isLoading
            ? Center(child: AdaptiveProgressIndicator())
            : RaisedButton(
                child: Text("Save"),
                textColor: Colors.white,
                onPressed: () => _submitForm(
                    model.addProduct,
                    model.updateProduct,
                    model.selectProduct,
                    model.selectedProductId),
              ),
      );
    });
  }

  void _setLocation(LocationData locData) {
    _formData['location'] = locData;
  }

  void _setImage(File image) {
    _formData['image'] = image;
  }

  void _submitForm(
      Function addProduct, Function updateProduct, Function setSelectedProduct,
      [String productId]) {
    if (!_formKey.currentState.validate()) {
      return;
    } else if (_formData['image'] == null && productId == null) {
      return;
    }
    _formKey.currentState.save();

    if (productId == null) {
      addProduct(
        _titleTextController.text,
        _descriptionTextController.text,
        _formData['image'],
        double.parse(_priceTextController.text.replaceFirst(',', '.')),
        _formData['location'],
      ).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/');
        } else {
          _somethingWrongDialog(context);
        }
      });
    } else {
      updateProduct(
        _titleTextController.text,
        _descriptionTextController.text,
        _formData['image'],
        double.parse(_priceTextController.text.replaceFirst(',', '.')),
        _formData['location'],
      ).then((bool success) {
        if (success) {
          Navigator.pushReplacementNamed(context, '/')
              .then((_) => setSelectedProduct(null));
        } else {
          _somethingWrongDialog(context);
        }
      });
    }
  }

  void _somethingWrongDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Something went wrong'),
            content: Text('Please try again!'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }
}
