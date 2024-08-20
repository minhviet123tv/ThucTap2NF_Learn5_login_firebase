class UserModel {
  final String? id;
  final String? name;
  final String? age;
  final String? country;

  UserModel({required this.id, required this.name, required this.age, required this.country,});

  toJson (){
    return {'id': id, "name": name,  "age": age, "country": country,};
  }
}
