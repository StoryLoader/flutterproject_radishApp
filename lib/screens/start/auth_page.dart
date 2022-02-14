import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:radish_app/constants/common_size.dart';
import 'package:radish_app/constants/shared_pref_keys.dart';
import 'package:radish_app/states/user_notifier.dart';
import 'package:provider/provider.dart';
import 'package:radish_app/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

const duration = Duration(milliseconds: 300);

class _AuthPageState extends State<AuthPage> {
  final inputBorder = OutlineInputBorder(borderSide: BorderSide(color: Colors.grey),);

  TextEditingController _phoneNumberController =
    TextEditingController(text:"010");

  TextEditingController _codeController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  VerificationStatus _verificationStatus = VerificationStatus.none;

  String? _verificationId;
  int? _forceResendingToken;


  @override
  void dispose() {
    _phoneNumberController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){

        Size size = MediaQuery.of(context).size;

        return IgnorePointer(
          ignoring: _verificationStatus == VerificationStatus.verifying,
          child: Form(
            key: _formKey,
            child: Scaffold(
              appBar: AppBar(
                title: Text('로그인 하기',
                    style: Theme.of(context).textTheme.headline6
                ),
                elevation: AppBarTheme.of(context).elevation,
              ),
              body: GestureDetector(
                onTap: (){
                  FocusScope.of(context).unfocus();
                },
                child: Padding(
                  padding: const EdgeInsets.all(common_bg_padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    Row(children: [
                      ExtendedImage.asset(
                          'assets/images/security.png',
                          width: size.width * 0.25,
                          height: size.width * 0.25
                      ),
                      SizedBox(width: common_sm_padding),
                      Text('무마켓은 전화번호로 가입합니다.\n여러분의 개인정보는 안전히 보관되며,\n외부에 노출되지 않습니다.',
                        style: TextStyle(fontSize: 13)),
                    ],),
                    SizedBox(height: common_bg_padding),
                    TextFormField(
                      validator: (phoneNumber){
                        if(phoneNumber != null && phoneNumber.length == 13) {
                          return null;
                        } else {
                          return '올바른 전화번호를 입력하세요.';
                        }
                      },
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [MaskedInputFormatter("000 0000 0000")],
                      decoration: InputDecoration(
                        border: inputBorder,
                        focusedBorder: inputBorder,
                      ),
                    ),
                    SizedBox(height: common_sm_padding),
                    TextButton(
                        onPressed: () async {
                          if(_verificationStatus == VerificationStatus.codeSending)
                            return;
                          if(_formKey.currentState != null) {
                            bool passed = _formKey.currentState!.validate();
                            print(passed);
                            if(passed) {
                              String phoneNum = _phoneNumberController.text;
                              phoneNum = phoneNum.replaceAll(' ', '');
                              phoneNum = phoneNum.replaceFirst('0', '');

                              FirebaseAuth auth = FirebaseAuth.instance;

                              setState(() {
                                _verificationStatus =
                                    VerificationStatus.codeSending;
                              });

                              await auth.verifyPhoneNumber(
                                phoneNumber: '+82$phoneNum',
                                forceResendingToken: _forceResendingToken,
                                verificationCompleted:
                                    (PhoneAuthCredential credential) async {
                                  logger
                                      .d('인증완료 - $credential');
                                  await auth.signInWithCredential(credential);
                                },
                                codeAutoRetrievalTimeout:
                                    (String verificationId) {},
                                codeSent: (String verificationId,
                                    int? forceResendingToken) async {
                                  setState(() {
                                    _verificationStatus =
                                        VerificationStatus.codeSent;
                                  });
                                  _verificationId = verificationId;
                                  _forceResendingToken = forceResendingToken;
                                },
                                verificationFailed:
                                    (FirebaseAuthException error) {
                                  logger.e(error.message);

                                  setState(() {
                                    _verificationStatus =
                                        VerificationStatus.none;
                                  });
                                },
                              );
                            }
                          }
                        },
                        child: (_verificationStatus == VerificationStatus.codeSending)
                            ?SizedBox(
                              height: 26,width: 26,
                              child: CircularProgressIndicator(color: Colors.white),)
                            :Text('인증번호 발송'),),
                    SizedBox(
                        height: common_bg_padding
                    ),
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      opacity: (_verificationStatus == VerificationStatus.none)
                          ?0
                          :1,
                      child: AnimatedContainer(
                        duration: duration,
                        curve: Curves.easeInOut,
                        height: getVerificationHeight(_verificationStatus),
                        child: TextFormField(
                            controller: _codeController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [MaskedInputFormatter("000000")],
                            decoration: InputDecoration(
                              border: inputBorder, focusedBorder: inputBorder),
                          ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeInOut,
                      height: getVerificationBtnHeight(_verificationStatus),
                      child: TextButton(
                          onPressed: () {
                            attemptVerify(context);
                          },
                          child: (_verificationStatus ==
                                  VerificationStatus.verifying)
                              ?CircularProgressIndicator(
                                  color: Colors.white
                                )
                              :Text('인증하기'),),),
                  ],),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  //인증번호 입력필드 show 애니메이션 변수값
  double getVerificationHeight(VerificationStatus status) {
    switch(status){

      case VerificationStatus.none:
        return 0;
      case VerificationStatus.codeSending:
      case VerificationStatus.codeSent:
      case VerificationStatus.verifying:
      case VerificationStatus.verificationDone:
        return 60 + common_sm_padding;

    }

  }

  //인증하기 버튼 show 애니메이션 변수값
  double getVerificationBtnHeight(VerificationStatus status) {
    switch(status){

      case VerificationStatus.none:
        return 0;
      case VerificationStatus.codeSending:
      case VerificationStatus.codeSent:
      case VerificationStatus.verifying:
      case VerificationStatus.verificationDone:
        return 48;

    }
  }


  // 인증하기 버튼 클릭시 인증중 처리함수
  void attemptVerify(BuildContext context) async {
    //인증처리 중인 상태관리
    setState(() {
      _verificationStatus = VerificationStatus.verifying;
    });
    try{
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: _codeController.text);
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch(e) {
      logger.e('인증실패!');
      SnackBar snackBar = SnackBar(content: Text('잘못된 인증코드입니다.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    //인증처리 완료 상태관리
    setState(() {
      _verificationStatus = VerificationStatus.verificationDone;
    });
  }

  _getAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String address = prefs.getString(SHARED_ADDRESS) ?? "";
    double lat = prefs.getDouble(SHARED_LAT) ?? 0;
    double lon = prefs.getDouble(SHARED_LON) ?? 0;
  }

  }


// 검증상태 관리
enum VerificationStatus {
  none,
  codeSending,
  codeSent,
  verifying,
  verificationDone
}

