class NativeName{
  final String official;
  final String common;

  NativeName({
    required this.official,
    required this.common,
  });

  factory NativeName.fromJson(Map<String, dynamic> json){
    return NativeName(
      official: json['official'] ?? '',
      common: json['common'] ?? '',
    );
  }
}