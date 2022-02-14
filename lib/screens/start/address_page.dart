import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:radish_app/constants/common_size.dart';
import 'package:radish_app/constants/shared_pref_keys.dart';
import 'package:radish_app/data/address_model.dart';
import 'package:radish_app/data/address_model2.dart';
import 'package:radish_app/screens/start/address_service.dart';
import 'package:radish_app/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class AddressPage extends StatefulWidget {
  AddressPage({Key? key}) : super(key: key);

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  TextEditingController _addressController = TextEditingController();

  AddressModel? _addressModel;
  List<AddressModel2> _addressModel2List = [];
  bool _isGettingLocation = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum:
          EdgeInsets.only(left: common_bg_padding, right: common_bg_padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _addressController,
            onFieldSubmitted: (text) async {
              _addressModel2List.clear();
              _addressModel = await AddressService().searchAddressByStr(text);
              setState(() {});
            },
            decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey,
                ),
                hintText: '도로명으로 검색',
                hintStyle: TextStyle(color: Theme.of(context).hintColor),
                border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                prefixIconConstraints:
                    BoxConstraints(minWidth: 24, minHeight: 24)),
          ),
          TextButton.icon(
            onPressed: () async {
              _addressModel = null;
              _addressModel2List.clear();
              setState(() {
                _isGettingLocation = true;
              });
              Location location = new Location();

              bool _serviceEnabled;
              PermissionStatus _permissionGranted;
              LocationData _locationData;

              _serviceEnabled = await location.serviceEnabled();
              if (!_serviceEnabled) {
                _serviceEnabled = await location.requestService();
                if (!_serviceEnabled) {
                  return;
                }
              }

              _permissionGranted = await location.hasPermission();
              if (_permissionGranted == PermissionStatus.denied) {
                _permissionGranted = await location.requestPermission();
                if (_permissionGranted != PermissionStatus.granted) {
                  return;
                }
              }

              _locationData = await location.getLocation();
              logger.d(_locationData);
              List<AddressModel2> addresses = await AddressService()
                  .findAddressByCoordinate(
                      log: _locationData.longitude!,
                      lat: _locationData.latitude!);

              _addressModel2List.addAll(addresses);

              setState(() {
                _isGettingLocation = false;
              });
            },
            icon: _isGettingLocation
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    CupertinoIcons.compass,
                    color: Colors.white,
                    size: 20,
                  ),
            label: Text(
              _isGettingLocation ? '위치 찾는 중...' : '현재 위치 찾기',
              style: Theme.of(context).textTheme.button,
            ),
          ),
          if (_addressModel != null)
            Expanded(
              // 검색시 리스트
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: common_bg_padding),
                itemBuilder: (context, index) {
                  if (_addressModel == null ||
                      _addressModel!.result == null ||
                      _addressModel!.result!.items == null ||
                      _addressModel!.result!.items![index].address == null)
                    return Container();
                  return ListTile(
                    onTap: () {
                      _saveAddressAndGoToNextPage(
                          _addressModel!.result!.items![index].address!.road ??
                              "",
                          num.parse(
                              _addressModel!.result!.items![index].point!.y ??
                                  "0"),
                          num.parse(
                              _addressModel!.result!.items![index].point!.x ??
                                  "0"));
                    },
                    title: Text(
                        _addressModel!.result!.items![index].address!.road ??
                            ""),
                    subtitle: Text(
                        _addressModel!.result!.items![index].address!.parcel ??
                            ""),
                  );
                },
                itemCount: (_addressModel == null ||
                        _addressModel!.result == null ||
                        _addressModel!.result!.items == null)
                    ? 0
                    : _addressModel!.result!.items!.length,
              ),
            ),
          if (_addressModel2List.isNotEmpty)
            Expanded(
              //내 위치로 검색시 리스트
              child: ListView.builder(
                padding: EdgeInsets.symmetric(vertical: common_bg_padding),
                itemBuilder: (context, index) {
                  if (_addressModel2List[index].result == null ||
                      _addressModel2List[index].result!.isEmpty)
                    return Container();
                  return ListTile(
                    onTap: () {
                      _saveAddressAndGoToNextPage(
                          _addressModel2List[index].result![0].text ?? "",
                          num.parse(
                              _addressModel2List[index].input!.point!.y ?? "0"),
                          num.parse(_addressModel2List[index].input!.point!.x ??
                              "0"));
                    },
                    title:
                        Text(_addressModel2List[index].result![0].text ?? ""),
                    subtitle: Text(
                        _addressModel2List[index].result![0].zipcode ?? ""),
                  );
                },
                itemCount: _addressModel2List.length,
              ),
            ),
        ],
      ),
    );
  }

  _saveAddressAndGoToNextPage(String address, num lat, num lon) async {
    await _saveAddressOnSharedPreference(address, lat, lon);

    context.read<PageController>().animateToPage(2,
        duration: Duration(milliseconds: 500), curve: Curves.ease);
  }

  _saveAddressOnSharedPreference(String address, num lat, num lon) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SHARED_ADDRESS, address);
    await prefs.setDouble(SHARED_LAT, lat.toDouble());
    await prefs.setDouble(SHARED_LON, lon.toDouble());
  }
}
