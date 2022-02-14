class TimeCalculation {
  static String getTimeDiff(DateTime createdDate) {
    DateTime now = DateTime.now();  //현재시간 변수
    Duration timeDiff = now.difference(createdDate);  //생성시간과 시간차 변수
    if(timeDiff.inHours <= 1){return '방금 전';}
    else if(timeDiff.inHours <= 24){return '${timeDiff.inHours}시간 전';}
    else{return'${timeDiff.inDays}일 전';}
  }
}