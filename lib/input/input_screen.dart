import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:radish_app/constants/common_size.dart';
import 'package:provider/provider.dart';
import 'package:radish_app/data/item_model.dart';
import 'package:radish_app/repo/image_storage.dart';
import 'package:radish_app/repo/item_service.dart';
import 'package:radish_app/states/category_notifier.dart';
import 'package:radish_app/states/select_image_notifier.dart';
import 'package:radish_app/states/user_notifier.dart';
import 'package:radish_app/utils/logger.dart';
import 'multi_image_select.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({Key? key}) : super(key: key);

  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  bool _suggestPriceSelected = false;

  TextEditingController _priceController = TextEditingController();
  var _border =
      UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent));

  var _divider = Divider(
    height: 1,
    thickness: 1,
    color: Colors.grey[350],
    indent: common_bg_padding,
    endIndent: common_bg_padding,
  );

  bool isCreatingItem = false;

  TextEditingController _titleController = TextEditingController();
  TextEditingController _detailController = TextEditingController();

  void attemptCreateItem() async {
    if (FirebaseAuth.instance.currentUser == null) return;
    isCreatingItem = true;
    setState(() {});

    final String userKey = FirebaseAuth.instance.currentUser!.uid;
    final String itemKey = ItemModel.generateItemKey(userKey);

    List<Uint8List> images = context.read<SelectImageNotifier>().images;

    UserNotifier userNotifier = context.read<UserNotifier>();

    if (userNotifier.userModel == null) return;

    List<String> downloadUrls =
        await ImageStorage.uploadImages(images, itemKey);

    final num? price =
        num.tryParse(_priceController.text.replaceAll(new RegExp(r"\D"), ''));

    ItemModel itemModel = ItemModel(
      itemKey: itemKey,
      userKey: userKey,
      imageDownloadUrls: downloadUrls,
      title: _titleController.text,
      category: context.read<CategoryNotifier>().currentCategoryInEng,
      price: price ?? 0,
      negotiable: _suggestPriceSelected,
      detail: _detailController.text,
      address: userNotifier.userModel!.address,
      geoFirePoint: userNotifier.userModel!.geoFirePoint,
      createdDate: DateTime.now().toUtc(),
    );

    logger.d('upload finished - ${downloadUrls.toString()}');

    await ItemService()
        .createNewItem(itemModel, itemKey, userNotifier.user!.uid);

    //업로드 완료 후 자동으로 뒤로가기
    context.beamBack();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        Size _size = MediaQuery.of(context).size;
        return IgnorePointer(
          ignoring: isCreatingItem,
          child: Scaffold(
            appBar: AppBar(
              bottom: PreferredSize(
                preferredSize: Size(_size.width, 2),
                child: isCreatingItem
                    ? LinearProgressIndicator(minHeight: 2)
                    : Container(),
              ),
              leading: TextButton(
                onPressed: () {
                  context.beamBack(); //뒤로가기 속성 가져오기
                },
                style: TextButton.styleFrom(
                    primary: Colors.black87,
                    backgroundColor:
                        Theme.of(context).appBarTheme.backgroundColor),
                child: Text('뒤로', style: Theme.of(context).textTheme.bodyText2),
              ),
              actions: [
                TextButton(
                  onPressed: attemptCreateItem,
                  style: TextButton.styleFrom(
                      primary: Colors.black87,
                      backgroundColor:
                          Theme.of(context).appBarTheme.backgroundColor),
                  child:
                      Text('완료', style: Theme.of(context).textTheme.bodyText2),
                ),
              ],
              title: Text(
                '중고상품 업로드',
                style: Theme.of(context).textTheme.headline6,
              ),
              centerTitle: true,
            ),
            body: ListView(
              children: [
                MultiImageSelect(),
                SizedBox(
                  height: 15,
                ),
                _divider,
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: common_bg_padding),
                    hintText: '상품 제목',
                    border: _border,
                    enabledBorder: _border,
                    focusedBorder: _border,
                  ),
                ),
                _divider,
                ListTile(
                  onTap: () {
                    context.beamToNamed('/input/category_input');
                  },
                  dense: true,
                  title: Text(
                      context.watch<CategoryNotifier>().currentCategoryInKor),
                  trailing: Icon(Icons.navigate_next),
                ),
                _divider,
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        inputFormatters: [
                          MoneyInputFormatter(
                              trailingSymbol: '원', mantissaLength: 0),
                        ],
                        controller: _priceController,
                        onChanged: (value) {
                          setState(() {
                            if (value == '0원') {
                              _priceController.clear();
                            }
                          });
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: common_bg_padding),
                          hintText: '상품가격을 입력하세요',
                          border: _border,
                          enabledBorder: _border,
                          focusedBorder: _border,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: common_bg_padding),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _suggestPriceSelected = !_suggestPriceSelected;
                          });
                        },
                        label: Text(
                          '가격 제안 받기',
                          style: TextStyle(
                              color: _suggestPriceSelected
                                  ? Theme.of(context).primaryColor
                                  : Colors.black54),
                        ),
                        icon: Icon(
                            _suggestPriceSelected
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: _suggestPriceSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black54),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            primary: Colors.black38),
                      ),
                    ),
                  ],
                ),
                _divider,
                TextFormField(
                  controller: _detailController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: common_bg_padding),
                    hintText: '상품 및 필요한 세부설명을 입력해주세요.',
                    border: _border,
                    enabledBorder: _border,
                    focusedBorder: _border,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
