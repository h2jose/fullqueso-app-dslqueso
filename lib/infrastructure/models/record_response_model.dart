import 'dart:convert';

RecordResponse recordResponseFromJson(String str) => RecordResponse.fromJson(json.decode(str));

String recordResponseToJson(RecordResponse data) => json.encode(data.toJson());

class RecordResponse {
    String? rrn;
    int accountType;
    String amount;
    String batchNum;
    String date;
    String deviceSerial;
    int errorCode;
    String merchantId;
    String referenceNumber;
    String responseCode;
    String responseMessage;
    int result;
    String terminalId;
    String time;
    String tipAmount;
    String traceNumber;
    int transType;

    RecordResponse({
        this.rrn = '0',
        required this.accountType,
        required this.amount,
        required this.batchNum,
        required this.date,
        required this.deviceSerial,
        required this.errorCode,
        required this.merchantId,
        required this.referenceNumber,
        required this.responseCode,
        required this.responseMessage,
        required this.result,
        required this.terminalId,
        required this.time,
        required this.tipAmount,
        required this.traceNumber,
        required this.transType,
    });

    factory RecordResponse.fromJson(Map<String, dynamic> json) => RecordResponse(
        rrn: json["RRN"],
        accountType: json["accountType"] ?? 0,
        amount: json["amount"] ?? "",
        batchNum: json["batchNum"] ?? "",
        date: json["date"] ?? "",
        deviceSerial: json["deviceSerial"] ?? "",
        errorCode: json["errorCode"] ?? 0,
        merchantId: json["merchantID"] ?? "",
        referenceNumber: json["referenceNumber"] ?? "",
        responseCode: json["responseCode"] ?? "",
        responseMessage: json["responseMessage"] ?? "",
        result: json["result"] ?? -1,
        terminalId: json["terminalID"] ?? "",
        time: json["time"] ?? "",
        tipAmount: json["tipAmount"] ?? "",
        traceNumber: json["traceNumber"] ?? "",
        transType: json["transType"] ?? 0,
    );

    Map<String, dynamic> toJson() => {
        "RRN": rrn,
        "accountType": accountType,
        "amount": amount,
        "batchNum": batchNum,
        "date": date,
        "deviceSerial": deviceSerial,
        "errorCode": errorCode,
        "merchantID": merchantId,
        "referenceNumber": referenceNumber,
        "responseCode": responseCode,
        "responseMessage": responseMessage,
        "result": result,
        "terminalID": terminalId,
        "time": time,
        "tipAmount": tipAmount,
        "traceNumber": traceNumber,
        "transType": transType,
    };
}
