import 'package:chat_app/bloc/shuffle/shuffle_event.dart';
import 'package:chat_app/bloc/shuffle/shuffle_state.dart';
import 'package:chat_app/constants/constant.dart';
import 'package:chat_app/data/model/room.dart';
import 'package:chat_app/services/service_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class ShuffleBloc extends Bloc<ShuffleEvent, ShuffleBlocState>{
  ShuffleBloc(ShuffleBlocState initialState) : super(initialState);
  var serviceManager = new ServiceManager();

  @override
  Stream<ShuffleBlocState> mapEventToState(ShuffleEvent event) async* {
    if(event is ShuffleLoadingEvent){
      try{
        var response = http.get(Uri.parse(URL_BASE + "/"));

      }
      catch(e){

      }
      yield* _loadMoreShuffle();
    }
    else{
      yield* _loadedShuffle();
    }
  }

  Stream<ShuffleBlocState> _loadMoreShuffle() async*{

    yield ShuffleLoadingState();
  }

  Stream<ShuffleBlocState> _loadedShuffle() async*{
    final List<RoomShuffle> updateShuffle = List.from((state as ShuffleLoadedState).rooms);
    yield ShuffleLoadedState(updateShuffle);
  }

  Stream<ShuffleBlocState> _loadingShuffle() async*{
    yield ShuffleLoadingState();
  }
}