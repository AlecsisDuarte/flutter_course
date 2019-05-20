import 'package:flutter/material.dart';

import '../widgets/ui_elements/height_spacing.dart';

class ProductCreatePage extends StatefulWidget {
  final Function addProduct;

  ProductCreatePage(this.addProduct);

  @override
  State<StatefulWidget> createState() {
    return _ProductCreatePageState();
  }
}

class _ProductCreatePageState extends State<ProductCreatePage> {
  final Map<String, dynamic> _formData = {
    'title': null,
    'description': null,
    'price': 0,
    'image': 'assets/burgers.jpg'
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 760.0 ? 500.0 : deviceWidth * 0.95;
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
              _buildTitleTextField(),
              _buildDescriptionTextField(),
              _buildPriceTextField(),
              HeightSpacing(),
              RaisedButton(
                child: Text("Save"),
                textColor: Colors.white,
                onPressed: _submitForm,
              )
            ],
          ),
        )));
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
            ]);
      },
    );
  }

  Widget _buildTitleTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Product Title"),
      keyboardType: TextInputType.text,
      textCapitalization: TextCapitalization.words,
      validator: (String value) {
        if (value.isEmpty) {
          return "Title is required";
        } else if (value.length < 5) {
          return 'Title should be 5+ character long';
        }
        return null;
      },
      onSaved: (String value) => _formData['title'] = value,
    );
  }

  Widget _buildDescriptionTextField() {
    return TextFormField(
      maxLines: 3,
      decoration: InputDecoration(labelText: "Product Description"),
      keyboardType: TextInputType.multiline,
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
    );
  }

  Widget _buildPriceTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Product Price"),
      keyboardType: TextInputType.number,
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
    );
  }

  void _submitForm() {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();

    widget.addProduct(_formData['title'], _formData['description'],
        _formData['image'], _formData['price']);
    Navigator.pushReplacementNamed(context, '/');
  }
}
