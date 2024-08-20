class UserModel {
  // final String? id;
  final String? age;
  final String? country;
  final String? name;
  final String? id;

  UserModel({required this.age, required this.country, required this.name, required this.id});

  toJson (){
    return {"age": age, "country": country, "name": name, 'id': id};
  }
}
