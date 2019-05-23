import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart' as GeoLoc;

import 'package:flutter_course/widgets/ui_elements/height_spacing.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_course/models/product.dart';
import '../helpers/ensure_visible_when_focused.dart';
import '../../models/location_data.dart';
import '../../shared/global_config.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Product product;

  LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return LocationInputState();
  }
}

class LocationInputState extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng _dummyPosition = LatLng(32.6077995, -115.475611);
  final CameraPosition _cameraPosition = CameraPosition(
    target: _dummyPosition,
    zoom: 14.4746,
  );
  final Set<Marker> _markers = Set<Marker>();
  final TextEditingController _addressInputController = TextEditingController();
  LocationData _locationData;

  bool isMapVisible = false;

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if (widget.product != null) {
      _addressInputController.text = widget.product.location.address;
      _setMarker(locData: widget.product.location);
    }
    super.initState();
  }

  @override
  void dispose() {
    _addressInputFocusNode.removeListener(_updateLocation);
    _addressInputFocusNode.dispose();
    super.dispose();
  }

  void _setMarker({LocationData locData, String address = ''}) async {
    if (address.isEmpty && locData == null) {
      setState(() => isMapVisible = false);
      widget.setLocation(null);
      return;
    }

    try {
      Address position;
      if (locData == null) {
        position = (await Geocoder.local.findAddressesFromQuery(address)).first;
        _locationData = LocationData(
          latitude: position.coordinates.latitude,
          longitude: position.coordinates.longitude,
          address: position.addressLine,
        );
      } else {
        _locationData = locData;
      }
    } catch (error) {
      print(error);
      setState(() => isMapVisible = false);
      return;
    }

    final LatLng latLng =
        LatLng(_locationData.latitude, _locationData.longitude);

    setState(() {
      isMapVisible = true;
      _addressInputController.text = _locationData.address;
    });

    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 13)));

    _markers.clear();
    if (mounted) {
      setState(() => _markers.add(Marker(
          markerId: MarkerId(latLng.toString()),
          position: latLng,
          infoWindow: InfoWindow(
            title: _locationData.address,
          ),
          icon: BitmapDescriptor.defaultMarker)));
    }
    widget.setLocation(_locationData);
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      _setMarker(address: _addressInputController.text);
    }
  }

  void _getUserLocation() async {
    final GeoLoc.Location location = GeoLoc.Location();

    try {
      final GeoLoc.LocationData currentLocation = await location.getLocation();
      final String address = await _getAddressByCoordinates(Coordinates(
        currentLocation.latitude,
        currentLocation.longitude,
      ));

      final LocationData locData = LocationData(
        address: address,
        latitude: currentLocation.latitude,
        longitude: currentLocation.longitude,
      );

      _setMarker(locData: locData);
    } catch (error) {
      await showDialog(
          builder: (BuildContext context) => AlertDialog(
                title: Text('Couldn\'t fetch your location'),
              ),
          context: this.context);
    }
  }

  Future<String> _getAddressByCoordinates(Coordinates coordinates) {
    GlobalConfig config = GlobalConfig();
    return Geocoder.google(config.config.geocodingKey)
        .findAddressesFromCoordinates(coordinates)
        .then((List<Address> addresses) {
      return addresses.first.addressLine;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          focusNode: _addressInputFocusNode,
          child: TextFormField(
            controller: _addressInputController,
            decoration: InputDecoration(
              labelText: 'Address',
              hintText: 'London, England',
              // prefixIcon: Icon(Icons.location_on),
              suffixIcon: IconButton(
                padding: EdgeInsets.all(0),
                icon: Icon(Icons.gps_fixed),
                onPressed: _getUserLocation,
              ),
            ),
            validator: (String value) {
              if (_locationData == null || value.isEmpty) {
                return 'No valid location found.';
              }
            },
            focusNode: _addressInputFocusNode,
          ),
        ),
        // HeightSpacing(),
        // FlatButton(
        //   child: Text('Current Location'),
        //   onPressed: _getUserLocation,
        // ),
        HeightSpacing(),
        isMapVisible
            ? Container(
                height: 300.0,
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _cameraPosition,
                  onMapCreated: (GoogleMapController controller) {
                    if (!_controller.isCompleted) {
                      _controller.complete(controller);
                    }
                  },
                  markers: _markers,
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                ),
              )
            : Container(),
      ],
    );
  }
}
