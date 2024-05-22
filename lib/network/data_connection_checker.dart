import 'dart:async';
import 'package:data_connection_checker/data_connection_checker.dart';

class DataConnectivityService {
  StreamController<DataConnectionStatus> connectivityStreamController =
      StreamController<DataConnectionStatus>();
  DataConnectivityService() {
    DataConnectionChecker().onStatusChange.listen((dataConnectionStatus) {
      connectivityStreamController.add(dataConnectionStatus);
    });
  }
  static networkCatcher(Function function) {
    var res = function;
    return res;

    // on SocketException catch(e){
    //           Provider.of<NetworkModel>(context, listen: false).updateStatus(false);
    //           return null;


    // }
  }
}
