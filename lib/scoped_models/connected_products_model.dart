import 'dart:async';
import 'dart:io';
import 'package:flutter_course/models/location_data.dart';
import 'package:flutter_course/models/user.dart';
import 'package:http_parser/http_parser.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mime/mime.dart';

import 'package:flutter_course/models/product.dart';
import '../models/auth.dart';

mixin ConnectedProductsModel on Model {
  final String _baseUrl = 'https://flutter-courser.firebaseio.com/';
  List<Product> _products = [];
  User _authenticatedUser;
  String _selProductId;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
}

mixin ProductsModel on ConnectedProductsModel {
  bool _showFavorites = false;

  /// Gets a copy of the current products list
  List<Product> get allProducts => List.from(_products);

  String get selectedProductId => _selProductId;

  bool get displayFavoritesOnly => _showFavorites;

  Product get selectedProduct {
    return _selProductId == null
        ? null
        : _products.firstWhere((p) => p.id == _selProductId);
  }

  List<Product> get displayProducts {
    if (_showFavorites) {
      return List.from(_products.where((p) => p.isFavorite));
    }
    return List.from(_products);
  }

  Future<Map<String, dynamic>> uploadImage(File image,
      {String imagePath}) async {
    final List<String> mimeTypeData = lookupMimeType(image.path).split('/');
    final Uri uri = Uri.parse(
        'https://us-central1-flutter-courser.cloudfunctions.net/storeImage');
    final http.MultipartRequest imageUploadRequest =
        http.MultipartRequest('POST', uri);
    final http.MultipartFile file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(
        mimeTypeData[0],
        mimeTypeData[1],
      ),
    );
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }
    imageUploadRequest.headers['authorization'] =
        'Bearer ${_authenticatedUser.token}';
    try {
      final streamResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Something went wrong: ${response.body}');
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  /// Adds a [Product] to our list
  Future<bool> addProduct(String title, String description, File image,
      double price, LocationData locData) async {
    _isLoading = true;
    notifyListeners();

    final uploadResponse = await uploadImage(image);

    if (uploadResponse == null) {
      _isLoading = false;
      notifyListeners();
      print('Upload failed');
      return false;
    }

    final Map<String, dynamic> productData = {
      'title': title,
      'description': description,
      'imagePath': uploadResponse['imagePath'],
      'imageUrl': uploadResponse['imageUrl'],
      'price': price,
      'userEmail': _authenticatedUser.email,
      'userId': _authenticatedUser.id,
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address
    };
    return http
        .post(
      _baseUrl + 'products.json?auth=${_authenticatedUser.token}',
      body: json.encode(productData),
    )
        .then((http.Response response) {
      if (response.statusCode != 200 && response.statusCode != 201) {
        _isLoading = false;
        this.notifyListeners();
        return false;
      }
      final Map<String, dynamic> responseData = json.decode(response.body);

      final Product newProduct = Product(
        id: responseData['name'],
        title: title,
        description: description,
        image: uploadResponse['imageUrl'],
        imagePath: uploadResponse['imagePath'],
        price: price,
        userEmail: _authenticatedUser.email,
        location: locData,
        userId: _authenticatedUser.id,
      );

      _products.add(newProduct);
      _isLoading = false;
      this.notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      this.notifyListeners();
      return false;
    });
  }

  /// Deletes the [Product] of the list
  Future<bool> deleteProduct() {
    _isLoading = true;
    final String toDeleteId = selectedProduct.id;
    _products.removeWhere((p) => p.id == toDeleteId);
    _selProductId = null;

    return http
        .delete(_baseUrl +
            '/products/$toDeleteId.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      this.notifyListeners();
      return false;
    });
  }

  /// Updates the specified [Product]
  Future<bool> updateProduct(String title, String description, File image,
      double price, LocationData locData) async {
    _isLoading = true;
    final Product originalProduct = selectedProduct;
    String imageUrl = originalProduct.image;
    String imagePath = originalProduct.imagePath;

    if (image != null) {
      final uploadResponse = await uploadImage(image);

      if (uploadResponse == null) {
        _isLoading = false;
        notifyListeners();
        print('Upload failed');
        return false;
      }

      imageUrl = uploadResponse['imageUrl'];
      imagePath = uploadResponse['imagePath'];
    }

    final Map<String, dynamic> updateData = {
      'title': title,
      'description': description,
      'price': price,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'userEmail': originalProduct.userEmail,
      'userId': originalProduct.userId,
      'loc_lat': locData.latitude,
      'loc_lng': locData.longitude,
      'loc_address': locData.address
    };

    try {
      await http.put(
          _baseUrl +
              '/products/${originalProduct.id}.json?auth=${_authenticatedUser.token}',
          body: json.encode(updateData));

      final Product updatedProduct = Product(
        id: originalProduct.id,
        title: title,
        description: description,
        price: price,
        image: imageUrl,
        imagePath: imagePath,
        userEmail: originalProduct.userEmail,
        userId: originalProduct.userId,
        location: locData,
        isFavorite: originalProduct.isFavorite,
      );
      final int selectedProductIndex =
          _products.indexWhere((p) => p.id == _selProductId);
      _products[selectedProductIndex] = updatedProduct;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _isLoading = false;
      this.notifyListeners();
      return false;
    }
  }

  void selectProduct(String productId) {
    _selProductId = productId;
    if (productId != null) {
      notifyListeners();
    }
  }

  /// Updates the [Product] favorite status
  Future<Null> toggleproductFavoriteStatus() async {
    final Product selectedProduct = this.selectedProduct;

    final Product updateProduct = Product(
        id: selectedProduct.id,
        title: selectedProduct.title,
        description: selectedProduct.description,
        price: selectedProduct.price,
        image: selectedProduct.image,
        imagePath: selectedProduct.imagePath,
        isFavorite: !selectedProduct.isFavorite,
        userEmail: selectedProduct.userEmail,
        location: selectedProduct.location,
        userId: selectedProduct.userId);

    final int selectedProductIndex =
        _products.indexWhere((p) => p.id == selectedProduct.id);
    _products[selectedProductIndex] = updateProduct;
    // _selProductId = null;
    this.notifyListeners();

    http.Response response;

    final String url =
        '$_baseUrl/products/${selectedProduct.id}/wishlistUsers/${_authenticatedUser.id}.json?auth=${_authenticatedUser.token}';
    if (!selectedProduct.isFavorite) {
      response = await http.put(url, body: json.encode(true));
    } else {
      response = await http.delete(url);
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      final Product updateProduct = Product(
          id: selectedProduct.id,
          title: selectedProduct.title,
          description: selectedProduct.description,
          price: selectedProduct.price,
          image: selectedProduct.image,
          imagePath: selectedProduct.imagePath,
          isFavorite: selectedProduct.isFavorite,
          userEmail: selectedProduct.userEmail,
          location: selectedProduct.location,
          userId: selectedProduct.userId);

      final int selectedProductIndex =
          _products.indexWhere((p) => p.id == selectedProduct.id);
      _products[selectedProductIndex] = updateProduct;
      this.notifyListeners();
    }
  }

  void toggleDisplayMode() {
    _showFavorites = !_showFavorites;
    this.notifyListeners();
  }

  Future<bool> fetchProducts(
      {bool onlyForUser = false, clearProducts = false}) {
    _isLoading = true;
    if (clearProducts) {
      _products = [];
    }
    notifyListeners();

    return http
        .get(_baseUrl + '/products.json?auth=${_authenticatedUser.token}')
        .then((http.Response response) {
      final List<Product> fetchedProductList = [];

      final Map<String, dynamic> productListData = json.decode(response.body);
      if (productListData == null) {
        _isLoading = false;
        _products = [];
        notifyListeners();
        return true;
      }

      productListData.forEach((String id, dynamic productData) {
        Map<String, dynamic> whislistUsers = productData['wishlistUsers'];
        final Product product = Product(
          id: id,
          title: productData['title'],
          description: productData['description'],
          image: productData['imageUrl'],
          imagePath: productData['imagePath'],
          price: productData['price'],
          userEmail: productData['userEmail'],
          userId: productData['userId'],
          location: LocationData(
            address: productData['loc_address'],
            latitude: productData['loc_lat'],
            longitude: productData['loc_lng'],
          ),
          isFavorite: whislistUsers == null
              ? false
              : whislistUsers.containsKey(_authenticatedUser.id),
        );

        fetchedProductList.add(product);
      });

      _products = onlyForUser
          ? fetchedProductList
              .where((Product p) => p.userId == _authenticatedUser.id)
              .toList()
          : fetchedProductList;
      _isLoading = false;
      notifyListeners();
      return true;
    }).catchError((error) {
      _isLoading = false;
      this.notifyListeners();
      return false;
    });
  }
}

mixin UsersModel on ConnectedProductsModel {
  Timer _authTimer;
  PublishSubject<bool> _userSubject = PublishSubject();

  User get user => _authenticatedUser;

  PublishSubject<bool> get userSubject => _userSubject;

  final String _authRoute =
      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/';
  final String _apiKey = 'AIzaSyAKcCTDcjC7Z_aX1IWxBtKfhXCkxuUu1cI';

  Future<Map<String, dynamic>> authenticate(String email, String password,
      [AuthMode mode = AuthMode.Login]) async {
    _isLoading = true;
    notifyListeners();
    Map<String, dynamic> authData = {
      'email': email,
      'password': password,
      'returnSecureToken': true,
    };

    String url = _authRoute;
    if (mode == AuthMode.Login) {
      url += 'verifyPassword?key=$_apiKey';
    } else {
      url += 'signupNewUser?key=$_apiKey';
    }

    final http.Response response = await http.post(
      url,
      body: json.encode(authData),
      headers: {'Content-Type': 'application/json'},
    );

    final Map<String, dynamic> responseData = json.decode(response.body);
    bool hasError = true;
    String message = '';
    if (responseData.containsKey('idToken')) {
      hasError = false;
      _authenticatedUser = User(
        id: responseData['localId'],
        email: responseData['email'],
        token: responseData['idToken'],
      );

      _userSubject.add(true);
      final int timeout = int.parse(responseData['expiresIn']);
      setAuthTimeout(timeout);
      final DateTime now = DateTime.now();
      final DateTime expiryTime = now.add(Duration(seconds: timeout));

      //User Data in application memory
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('token', _authenticatedUser.token);
      prefs.setString('userEmail', _authenticatedUser.email);
      prefs.setString('userId', _authenticatedUser.id);
      prefs.setString('expiryTime', expiryTime.toString());

      message = 'Authentication succeeded!';
    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
      message = 'This email was not found.';
    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
      message = 'This password is invalid.';
    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
      message = 'This email already exists.';
    }

    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  Future<bool> autoAuthenticate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String token = prefs.getString('token');

    if (token == null) {
      return false;
    }

    //Verify if token hasn't expire
    final String expiryTimeString = prefs.getString('expiryTime');
    final DateTime now = DateTime.now();
    final DateTime parsedExpiryTime = DateTime.parse(expiryTimeString);
    if (parsedExpiryTime.isBefore(now)) {
      _authenticatedUser = null;
      notifyListeners();
      return false;
    }

    final String userEmail = prefs.getString('userEmail');
    final String userId = prefs.getString('userId');
    final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;

    _authenticatedUser = User(id: userId, email: userEmail, token: token);
    setAuthTimeout(tokenLifespan);
    _userSubject.add(true);
    return true;
  }

  Future<Null> logout() async {
    print('logout');
    _authenticatedUser = null;
    _authTimer.cancel();
    _userSubject.add(false);
    _selProductId = null;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('userEmail');
    prefs.remove('userId');
  }

  void setAuthTimeout(int time) {
    _authTimer = Timer(Duration(seconds: time), logout);
  }
}
