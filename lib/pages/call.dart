// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';
import 'package:agora_rtc_engine/rtc_local_view.dart' as rtc_local_view;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as rtc_remote_view;
import '../utils/settings.dart';
class CallPage extends StatefulWidget {
  const CallPage({super.key,this.channelName, this.role});
  final String? channelName;
  final ClientRole? role;
  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false;
  bool _viewPanel=false;
  late RtcEngine _engine;
  

  @override
  void initState() {
    
    initialize();

    super.initState();
  }

  Future<void> initialize()async{
  _engine = await RtcEngine.create(appId);
    if(appId.isEmpty){
      setState(() {
        _infoStrings.add(
          "APP_ID missing, please provide your APP_ID in settings.dart"
        );
        _infoStrings.add("Agora Engine is not starting");
      });
      return;
    }
    // _engine= await RtcEngine.create(appId);
    await _engine.enableVideo();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await _engine.setClientRole(widget.role!);
    _addAgoraEventHandlers();
    VideoEncoderConfiguration configuration = VideoEncoderConfiguration();
    configuration.dimensions = VideoDimensions(width:500, height:520);
    await _engine.setVideoEncoderConfiguration(configuration);
    await _engine.joinChannel(token, widget.channelName!, null, 0);
  }

  void _addAgoraEventHandlers(){
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code){
        final info = 'onError: $code';
        setState(() {
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel,uid,elapsed){
        final info = 'onJoinChannel: $channel, uid: $uid';
        setState(() {
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stats){
        final info = 'onLeaveChannel';
        setState(() {
          _infoStrings.add(info);
          _users.clear();
        });
      },
      userJoined: (uid,elapsed){
        final info = 'userJoined: $uid';
        setState(() {
          _infoStrings.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid,reason){
        final info = 'userOffline: $uid';
        setState(() {
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
      firstRemoteVideoFrame: (uid,width,height,elapsed){
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        setState(() {
          _infoStrings.add(info);
        });
      },
    ));
  }

  Widget _viewRows(){
    final List<StatefulWidget> list = [];
    if(widget.role==ClientRole.Broadcaster){
      list.add(rtc_local_view.SurfaceView());
    }
    _users.forEach((int uid) => list.add(
    (rtc_remote_view.SurfaceView(uid: uid,channelId: widget.channelName!,))
    ));
    final views=list;
    return Column(children: List.generate(views.length, (index) => Expanded(child: views[index]),),);
  }

  Widget _toolbar(){
    if (widget.role == ClientRole.Audience) {
      return Container();
    }
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: ()async{
              setState(() {
                muted=!muted;
              });
             _engine = await RtcEngine.create(appId);
              _engine.muteLocalAudioStream(muted);
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
          ),
          RawMaterialButton(
            onPressed: (() => Navigator.pop(context)),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
          ),
          RawMaterialButton(
            onPressed: (){
              _engine.switchCamera();
            },
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
            child: const Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel(){
    return Visibility(
      visible: _viewPanel,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 48),
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.5,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: ListView.builder(
              reverse: true,
              itemCount: _infoStrings.length,
              itemBuilder: (BuildContext context, int index){
                if(_infoStrings.isEmpty){
                  return Text("null");
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.yellowAccent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            _infoStrings[index],
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text("WeMeet"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: (){
              setState(() {
                _viewPanel=!_viewPanel;
              });
            },
            icon: Icon(Icons.info),
          )
        ],
        
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}