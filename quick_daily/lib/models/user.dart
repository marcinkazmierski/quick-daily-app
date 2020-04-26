class User {
  int id;
  String externalId;
  String name;
  String description;
  String imageUrl;
  int speakingVolume = 0;
  bool muted = false;
  String state = 'inactive';

  User({this.id, this.externalId, this.name, this.description, this.imageUrl});

  factory User.fromJson(Map<String, dynamic> item) {
    return User(
      id: item['id'].toInt(),
      name: item['nick'].toString(),
      description: 'todo: description',
      //todo
      externalId: item['externalId'].toString(),
      imageUrl: item['avatar'].toString(),
    );
  }
}
