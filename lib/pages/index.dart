import 'package:flutter/material.dart';
import 'dart:async';
import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer';
import 'call.dart';
class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final _channelController = TextEditingController();
  bool _validateError=false;
  ClientRole? _role = ClientRole.Broadcaster;

  @override
  void dispose() {
    _channelController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WeMeet"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(child: 
      Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(children: [
          SizedBox(height: 40,),
          Image.network("https://cdn-icons-png.flaticon.com/512/7185/7185630.png",height: 200,),
          SizedBox(height: 20,),
          TextField(
            controller: _channelController,
            decoration: InputDecoration(
              errorText: _validateError ? "Channel name is mandatory" : null,
              border: OutlineInputBorder(),
              labelText: "Channel name",
            ),
          ),
          RadioListTile(value: ClientRole.Broadcaster, 
          groupValue: _role, 
          onChanged: (ClientRole?value){
            setState(() {
              _role = value;
            });
          }, 
          title: Text("Broadcaster")),
          RadioListTile(value: ClientRole.Audience, groupValue: _role,
          title: Text("Audience"),
          onChanged: (ClientRole?value){
            setState(() {
              _role = value;
            });
          }),
          ElevatedButton(onPressed: onJoin, child: Text("Join",),style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),),
        ],)
      )),
    );
  }
  Future<void> onJoin() async{
    setState(() {
      _channelController.text.isEmpty ? 
      _validateError = true:_validateError = false;
    });
    if(_channelController.text.isNotEmpty){

      await _handleCamandMic(Permission.camera);
      await _handleCamandMic(Permission.microphone);
    
     await Navigator.push(context, MaterialPageRoute(builder: (context)=>CallPage(channelName: _channelController.text,role: _role,)));
    }
  }
  Future<void> _handleCamandMic(Permission permission) async{
    final status = await permission.request();
    log(status.toString());
  }
}