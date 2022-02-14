import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:radish_app/constants/common_size.dart';
import 'package:radish_app/data/item_model.dart';
import 'package:radish_app/repo/item_service.dart';
import 'package:radish_app/repo/user_service.dart';
import 'package:radish_app/router/locations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:beamer/beamer.dart';

class ItemsPage extends StatelessWidget {
  const ItemsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){

        Size size = MediaQuery.of(context).size;
        final imgSize = size.width / 4;

        return FutureBuilder<List<ItemModel>>(
          future: ItemService().getItems(),
          builder: (context, snapshot) {
            return AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                child: (snapshot.hasData && snapshot.data!.isNotEmpty)
                    ?_listView(imgSize, snapshot.data!)
                    :_shimmerListView(imgSize)
            );
          });
      },
    );
  }

  ListView _listView(double imgSize, List<ItemModel>items) {
    return ListView.separated(
          separatorBuilder: (context, index){
            return Divider(
              height: common_sm_padding * 3,  //높이
              thickness: 1,  // 구분선
              color: Colors.grey[200],  // 구분석 색
              indent: common_sm_padding,  // 좌측 구분선 패딩
              endIndent: common_sm_padding,  // 우측 구분선 패딩
            );
          },
          padding: EdgeInsets.all(common_bg_padding),
          itemBuilder: (context, index){
            ItemModel item = items[index];
            return InkWell(
              onTap: (){
                context.beamToNamed('/$LOCATION_ITEM/:${item.itemKey}');
              },
              child: SizedBox(
                height: imgSize,
                child: Row(
                  children: [
                    SizedBox(
                      height: imgSize,
                      width: imgSize,
                      child: ExtendedImage.network(
                        item.imageDownloadUrls[0],
                        fit: BoxFit.cover,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(width: common_bg_padding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: Theme.of(context).textTheme.subtitle1),
                          SizedBox(height: 7),
                          Text('1시간 전', style: Theme.of(context).textTheme.subtitle2),
                          SizedBox(height: 7),
                          Text('${item.price.toString()}원'),
                          Expanded(child: Container(),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 15,
                                child: FittedBox(
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.chat_bubble_2, color: Colors.grey),
                                      Text('31', style: TextStyle(color: Colors.grey),),
                                      Icon(CupertinoIcons.heart, color: Colors.grey),
                                      Text('31', style: TextStyle(color: Colors.grey),),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
          itemCount: items.length);
  }

  Widget _shimmerListView(double imgSize) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      enabled: true,
      child: ListView.separated(
            padding: EdgeInsets.all(common_bg_padding),
            separatorBuilder: (context, index){
              return Divider(
                height: common_sm_padding * 3,  //높이
                thickness: 1,  // 구분선
                color: Colors.grey[200],  // 구분석 색
                indent: common_sm_padding,  // 좌측 구분선 패딩
                endIndent: common_sm_padding,  // 우측 구분선 패딩
              );
            },
            itemBuilder: (context, index){
              return SizedBox(
                height: imgSize,
                child: Row(
                  children: [
                    Container(
                      height: imgSize,
                      width: imgSize,
                      decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    SizedBox(width: common_bg_padding),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 25,
                            width: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          SizedBox(height: 7),
                          Container(
                            height: 18,
                            width: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          SizedBox(height: 7),
                          Container(
                            height: 20,
                            width: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          Expanded(child: Container(),),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 16,
                                width: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
            itemCount: 50),
    );
  }
}
