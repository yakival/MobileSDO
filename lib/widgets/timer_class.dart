import 'dart:async';
import 'package:flutter_lifecycle_aware/lifecycle_observer.dart';
import 'package:flutter_lifecycle_aware/lifecycle_owner.dart';
import 'package:flutter_lifecycle_aware/lifecycle_state.dart';
import '../database/ItemModel.dart';
import 'http_post.dart';

class AViewModel extends LifecycleObserver {
  ///resources to be released
  Timer? _timer;
  Item _args = Item();
  int? idlog;

  ///initData
  void initData() {
    if(_args.id != null){
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(minutes: 1), (Timer timer) async {
        _args.time = (_args.time ?? 0) + 1;
        updateItem(_args!);
        var res = await httpAPI(
            "close/students/sync.asp",
            '{"id":"' + _args.guid! + '", "idlog": ' + ((idlog == null)?"null":idlog.toString()) +
                ', "type":"RATEBOOK", "data": 1}',
            null);
        var json = res as Map<String, dynamic>;
        idlog = json["idlog"];
      });
    }
  }

  ///destroy/release resources
  void destroy() {
    _timer?.cancel();
  }

  void setData(Item args) {
    if(args.id == null){
      return;
    }
    _args = args;
    /*
    _timer ??=
        Timer.periodic(const Duration(minutes: 1), (Timer timer) async {
        _args.time = (_args.time ?? 0) + 1;
        updateItem(_args!);
        var res = await httpAPI(
            "close/students/sync.asp",
            '{"id":"' + _args.guid! + '", "idlog": ' + ((idlog == null)?"null":idlog.toString()) +
                ', "type":"RATEBOOK", "data": 1}',
            null);
        var json = res as Map<String, dynamic>;
        idlog = json["idlog"];
      });
     */
  }

  ///Lifecycle callback listener
  @override
  void onLifecycleChanged(LifecycleOwner owner, LifecycleState state) {
    if (state == LifecycleState.onStart) {
      initData();
    } else if (state == LifecycleState.onStop) {
      destroy();
    }
  }
}