class Charts {
  Charts({
    required this.calT,
    required this.carT,
    required this.fatT,
    required this.name,
    required this.proT,
    required this.saltT,
    required this.sugT,
    required this.time,
    required this.volT,
  });

  late int calT;
  late int carT;
  late int fatT;
  late String name;
  late int proT;
  late int saltT;
  late int sugT;
  late int time;
  late int volT;

  Charts.fromJson(Map<String, dynamic> json) {
    calT = json['cal_t'] ?? 0;
    carT = json['car_t'] ?? 0;
    fatT = json['fat_t'] ?? 0;
    name = json['name'] ?? 'start';
    proT = json['pro_t'] ?? 0;
    saltT = json['salt_t'] ?? 0;
    sugT = json['sug_t'] ?? 0;
    time = json['time'] ?? 0;
    volT = json['vol_t'] ?? 0;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['cal_t'] = calT;
    data['car_t'] = carT;
    data['fat_t'] = fatT;
    data['name'] = name;
    data['pro_t'] = proT;
    data['salt_t'] = saltT;
    data['sug_t'] = sugT;
    data['time'] = time;
    data['vol_t'] = volT;
    return data;
  }
}
