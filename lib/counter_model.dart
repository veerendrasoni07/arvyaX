class CounterModel{


  final String id;
  final String ambienceName;
  final int count;

  CounterModel({required this.ambienceName,this.count = 0,required this.id});

  CounterModel copyWith({String? ambienceName,int? count}){
    return CounterModel(
      ambienceName: ambienceName ?? this.ambienceName,
      count: count ?? this.count,
      id: id
    );
  }

}