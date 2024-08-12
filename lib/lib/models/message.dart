class Message {
  Message({
    required this.msg,
    required this.read,
    required this.told,
    required this.fromld,
    required this.sent,
    required this.type,
  });

  late final String msg;
  late final String read;
  late final String told;
  late final String fromld;
  late final String type;
  //텍스트와 이미지라서 각 경우에 따라 다르게 처리해야함

  late final String sent;

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    read = json['read'].toString();
    told = json['told'].toString();
    fromld = json['fromld'].toString();
    sent = json['sent'].toString();
    type = json['type'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['msg'] = msg;
    data['read'] = read;
    data['told'] = told;
    data['fromld'] = fromld;
    data['sent'] = sent;
    data['type'] = type;

    return data;
  }
}

enum Type { text, image }
