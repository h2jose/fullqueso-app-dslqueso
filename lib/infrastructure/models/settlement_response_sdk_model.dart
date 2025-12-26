import 'dart:convert';

SettlementResponse settlementResponseFromJson(String str) => SettlementResponse.fromJson(json.decode(str));

String settlementResponseToJson(SettlementResponse data) => json.encode(data.toJson());

class SettlementResponse {
    String? creditBatchNo;
    String? debitBatchNo;
    String? extraBatchNo;
    String? rrn;
    int? accountType;
    String? date;
    String? deviceSerial;
    int? errorCode;
    String? merchantId;
    String? referenceNumber;
    String? responseCode;
    String? responseMessage;
    int? result;
    String? terminalId;
    String? time;
    String? tipAmount;
    String? totalCreditCardRefund;
    String? totalCreditCardSale;
    String? totalDebitCardRefund;
    String? totalDebitCardSale;
    String? totalExtraRefund;
    String? totalExtraSale;
    String? traceNumber;
    int? transType;

    SettlementResponse({
        this.creditBatchNo,
        this.debitBatchNo,
        this.extraBatchNo,
        this.rrn,
        this.accountType,
        this.date,
        this.deviceSerial,
        this.errorCode,
        this.merchantId,
        this.referenceNumber,
        this.responseCode,
        this.responseMessage,
        this.result,
        this.terminalId,
        this.time,
        this.tipAmount,
        this.totalCreditCardRefund,
        this.totalCreditCardSale,
        this.totalDebitCardRefund,
        this.totalDebitCardSale,
        this.totalExtraRefund,
        this.totalExtraSale,
        this.traceNumber,
        this.transType,
    });

    factory SettlementResponse.fromJson(Map<String, dynamic> json) => SettlementResponse(
        creditBatchNo: json["CreditBatchNo"],
        debitBatchNo: json["DebitBatchNo"],
        extraBatchNo: json["ExtraBatchNo"],
        rrn: json["RRN"],
        accountType: json["accountType"],
        date: json["date"],
        deviceSerial: json["deviceSerial"],
        errorCode: json["errorCode"],
        merchantId: json["merchantID"],
        referenceNumber: json["referenceNumber"],
        responseCode: json["responseCode"],
        responseMessage: json["responseMessage"],
        result: json["result"],
        terminalId: json["terminalID"],
        time: json["time"],
        tipAmount: json["tipAmount"],
        totalCreditCardRefund: json["totalCreditCardRefund"],
        totalCreditCardSale: json["totalCreditCardSale"],
        totalDebitCardRefund: json["totalDebitCardRefund"],
        totalDebitCardSale: json["totalDebitCardSale"],
        totalExtraRefund: json["totalExtraRefund"],
        totalExtraSale: json["totalExtraSale"],
        traceNumber: json["traceNumber"],
        transType: json["transType"],
    );

    Map<String, dynamic> toJson() => {
        "CreditBatchNo": creditBatchNo,
        "DebitBatchNo": debitBatchNo,
        "ExtraBatchNo": extraBatchNo,
        "RRN": rrn,
        "accountType": accountType,
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
        "totalCreditCardRefund": totalCreditCardRefund,
        "totalCreditCardSale": totalCreditCardSale,
        "totalDebitCardRefund": totalDebitCardRefund,
        "totalDebitCardSale": totalDebitCardSale,
        "totalExtraRefund": totalExtraRefund,
        "totalExtraSale": totalExtraSale,
        "traceNumber": traceNumber,
        "transType": transType,
    };
}
