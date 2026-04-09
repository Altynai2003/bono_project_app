class OrderModel {
  int? id;
  String userName;
  String modelName;
  int cutQuantity;
  String color;
  int pieceQuantity;
  String hardwareType;
  int shipmentQuantity;
  String cutDate;
  String status;

  OrderModel({
    this.id,
    required this.userName,
    required this.modelName,
    required this.cutQuantity,
    required this.color,
    required this.pieceQuantity,
    required this.hardwareType,
    required this.shipmentQuantity,
    required this.cutDate,
    this.status = 'Кесилди', // Дефолт статус
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'modelName': modelName,
      'cutQuantity': cutQuantity,
      'color': color,
      'pieceQuantity': pieceQuantity,
      'hardwareType': hardwareType,
      'shipmentQuantity': shipmentQuantity,
      'cutDate': cutDate,
      'status': status,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      userName: map['userName'] ?? 'Белгисиз',
      modelName: map['modelName'],
      cutQuantity: map['cutQuantity'],
      color: map['color'],
      pieceQuantity: map['pieceQuantity'],
      hardwareType: map['hardwareType'],
      shipmentQuantity: map['shipmentQuantity'],
      cutDate: map['cutDate'],
      status: map['status'] ?? 'Кесилди',
    );
  }
}
