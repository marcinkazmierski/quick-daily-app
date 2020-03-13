class Team {
  int id;
  String name;
  String description;
  String externalAppId;
  String imageUrl;

  Team(
      {this.id,
      this.name,
      this.description,
      this.externalAppId,
      this.imageUrl});

  factory Team.fromJson(Map<String, dynamic> item) {
    return Team(
      id: item['id'].toInt(),
      name: item['name'].toString(),
      description: item['description'].toString(),
      externalAppId: item['externalAppKey'].toString(),
      imageUrl: item['image'].toString(),
    );
  }
}
