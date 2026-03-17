

import 'package:arvyax/counter_model.dart';
import 'package:flutter_riverpod/legacy.dart';

class CounterProvider extends StateNotifier<List<CounterModel>>{

  CounterProvider():super([]);

  void increaseCounter(String id,String name){
    final index = state.indexWhere((item)=> item.id==id);
    if(index!=-1){
      state[index] = state[index].copyWith(count: state[index].count+1);
    }
    else {
      state = [...state, CounterModel(ambienceName: name, count: 1, id: id)];
    }

  }

  int getCounterData(String id){
    print("DAaaatttttttttttttttttttt");
    int count = state.firstWhere((item)=> item.id == id,orElse: ()=> CounterModel(ambienceName: '', count: 0, id: '')).count;
    print(count);
    return count;
  }
}
final counterProvider = StateNotifierProvider<CounterProvider,List<CounterModel>>((ref) => CounterProvider());