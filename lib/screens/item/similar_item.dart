import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:radish_app/data/item_model.dart';
import 'package:radish_app/screens/item/item_detail_screen.dart';

class SimilarItem extends StatelessWidget {
  final ItemModel _itemModel;
  const SimilarItem(this._itemModel, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ItemDetailScreen(_itemModel.itemKey);
        }));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 9 / 8,
            child: ExtendedImage.network(_itemModel.imageDownloadUrls[0],
                fit: BoxFit.cover,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(8)),
          ),
          SizedBox(height: 8),
          Text(
            _itemModel.title,
            style: Theme.of(context).textTheme.subtitle1,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8),
          Text('${_itemModel.price.toString()}원',
              style: Theme.of(context).textTheme.subtitle2),
        ],
      ),
    );
  }
}
