import 'package:extended_image/extended_image.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class IntroPage extends StatelessWidget {
  IntroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        Size size = MediaQuery.of(context).size;

        final imgOne = size.width - 32;
        final imgTwo = imgOne * 0.1;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  '무 마켓',
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                SizedBox(
                  width: imgOne,
                  height: imgOne,
                  child: Stack(
                    children: [
                      ExtendedImage.asset('assets/images/intro_one.png'),
                      Positioned(
                        width: imgTwo,
                        height: imgTwo,
                        left: imgOne * 0.45,
                        top: imgOne * 0.45,
                        child:
                            ExtendedImage.asset('assets/images/intro_two.png'),
                      ),
                    ],
                  ),
                ),
                Text(
                  '우리 동네 중고 직거래',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                ),
                Text(
                  '무마켓은 동네 직거래 마켓이에요.\n내 동네를 설정하고 시작해보세요!',
                  style: TextStyle(fontSize: 13),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextButton(
                      onPressed: () async {
                        context.read<PageController>().animateToPage(1,
                            duration: Duration(milliseconds: 700),
                            curve: Curves.easeOut);
                      },
                      child: Text(
                        '내 동네 설정하고 시작하기',
                        style: Theme.of(context).textTheme.button,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
