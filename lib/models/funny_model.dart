class FunnyModel {
  List<Results> results;

  FunnyModel({this.results});

  FunnyModel.fromJson(Map<String, dynamic> json) {
    if (json['results'] != null) {
      results = new List<Results>();
      json['results'].forEach((v) {
        results.add(new Results.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Results {
  String id;
  String videoTitle;
  String imageUrl;
  String videoId;
  String videoUrl;
  String videoSize;
  String videoCat;

  Results(
      {this.id,
        this.videoTitle,
        this.imageUrl,
        this.videoId,
        this.videoUrl,
        this.videoSize,
        this.videoCat});

  Results.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    videoTitle = json['videoTitle'];
    imageUrl = json['imageUrl'];
    videoId = json['videoId'];
    videoUrl = json['videoUrl'];
    videoSize = json['videoSize'];
    videoCat = json['videoCat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['videoTitle'] = this.videoTitle;
    data['imageUrl'] = this.imageUrl;
    data['videoId'] = this.videoId;
    data['videoUrl'] = this.videoUrl;
    data['videoSize'] = this.videoSize;
    data['videoCat'] = this.videoCat;
    return data;
  }
}