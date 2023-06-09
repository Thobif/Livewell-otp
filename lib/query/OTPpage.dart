import 'package:abc/query/name.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:pinput/pinput.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  OTPScreen(this.phone);
  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String? _verificationCode;
  final TextEditingController _pinPutController = TextEditingController();

  // ย้าย defaultPinTheme มาอยู่ที่นี่
  final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(fontSize: 20, color: Color.fromRGBO(30, 60, 87, 1), fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldkey,
      appBar: AppBar(
        title: Text('OTP Verification'),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'Verify ${widget.phone}',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
),
),
),
Padding(
padding: const EdgeInsets.all(30.0),
child: Pinput(
length: 6,
defaultPinTheme: defaultPinTheme, controller: _pinPutController,

          pinAnimationType: PinAnimationType.fade,
        ),
      ),
      // เพิ่มปุ่ม Verify OTP ที่นี่
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0),
        child: ElevatedButton(
          onPressed: () async {
            try {
              String pin = _pinPutController.text;
              await FirebaseAuth.instance
                  .signInWithCredential(PhoneAuthProvider.credential(
                      verificationId: _verificationCode!, smsCode: pin))
                  .then((value) async {
                if (value.user != null) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => FirstPage()),
                      (route) => false);
                }
              });
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));

            }
          },
          child: Text('Verify OTP'),
          style: ElevatedButton.styleFrom(
            primary: Theme.of(context).primaryColor,
            padding: EdgeInsets.symmetric(vertical: 16),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      )
    ],
  ),
);
  }

  _verifyPhone() async {
await FirebaseAuth.instance.verifyPhoneNumber(
phoneNumber: '+66${widget.phone}',
verificationCompleted: (PhoneAuthCredential credential) async {
await FirebaseAuth.instance
.signInWithCredential(credential)
.then((value) async {
if (value.user != null) {
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(builder: (context) => FirstPage()),
(route) => false);
}
});
},
verificationFailed: (FirebaseAuthException e) {
print(e.message);
},
codeSent: (String? verficationID, int? resendToken) {
setState(() {
_verificationCode = verficationID;
});
},
codeAutoRetrievalTimeout: (String verificationID) {
setState(() {
_verificationCode = verificationID;
});
},
timeout: Duration(seconds: 10));
}

@override
void initState() {
// TODO: implement initState
super.initState();
_verifyPhone();
}
}
