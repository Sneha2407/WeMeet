import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/material.dart';


class CallPage extends StatefulWidget {
  const CallPage({super.key,this.channelName, this.role});
  final String? channelName;
  final ClientRole? role;
  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Agora"),
        centerTitle: true,
      ),
    );
  }
}