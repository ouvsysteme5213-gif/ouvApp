import 'package:authentication/authentication.dart';
import 'package:flutter/material.dart';
import 'package:models/models.dart';
import 'package:provider/provider.dart';

class OuvCitations extends StatefulWidget{

  final OuvApp myApp;
  const OuvCitations({super.key, required this.myApp,});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OuvCitationsState();
  }
  
}
class OuvCitationsState extends State<OuvCitations>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.myApp.displayName),
        centerTitle: true,
      ),
      body: Consumer<AuthController>(
        builder: (context, authController, child) {

          return Center(
            child: Column(
              children: [
                Text("${authController.isAuthenticated}"),
                ElevatedButton(
                    onPressed: () => authController.logout(context),
                    child: Text('Dexonnexions')
                )
              ],
            )
          );
        }
      ),
    );
  }
  
}