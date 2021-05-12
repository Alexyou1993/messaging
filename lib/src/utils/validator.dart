import 'dart:core';

/// Validates that a value is a byte buffer.
///
/// @param {dynamic} value The value to validate.
/// @return {boolean} Whether the value is byte buffer or not.

bool? isBuffer(dynamic value) {
  if (value.runtimeType != List) {
    final List<dynamic> val = value as List<dynamic>;
    for(int idx = 0; idx< val.length; idx++){
      if(val[idx].runtimeType != int){
        return false;
      }
    }
  }
  return true;
}


/// Validates that a value is an List.
///
/// @param {dynamic} value The value to validate.
/// @return {boolean} Whether the value is an List or not.

bool? isList(dynamic value){
  if(value.runtimeType != List){
    return false;
  }
  return true;
}


/// Validates that a value is a non-empty array.
///
/// @param {dynamic} value The value to validate.
/// @return {boolean} Whether the value is a non-empty List or not.

bool? isNonEmptyList(dynamic value){
  if (value.runtimeType == List) {
    final List<dynamic> val = value as List<dynamic>;
    if(val.isEmpty){
      return false;
    }
  }
  return true;
}

/// Validates that a value is a boolean.
///
/// @param {dynamic} value The value to validate.
/// @return {boolean} Whether the value is a boolean or not.

bool? isBoolean(dynamic value){
  if(value.runtimeType != bool){
    return false;
  }
  return true;
}



/// Validates that a value is a string.
///
/// @param {dynamic} value The value to validate.
/// @return {boolean} Whether the value is a string or not.

bool? isString(dynamic value){
  if(value.runtimeType != String){
    return false;
  }
  return true;
}

/// Validates that a value is a base64 string.
///
/// @param {dynamic} value The value to validate.
/// @return {boolean} Whether the value is a base64 string or not.

bool? isBase64String(dynamic value) {

}

/// Validates that a value is a non-empty string.
///
/// @param {dynamic} value The value to validate.
/// @return {boolean} Whether the value is a non-empty string or not.

bool? isNonEmptyString(dynamic value){
  if(value.toString().isEmpty){
    return false;
  }
  return true;
}

/// Validates that a string is a valid Firebase Auth uid.
///
/// @param {dynamic} uid The string to validate.
/// @return {boolean} Whether the string is a valid Firebase Auth uid.

bool? isUid(dynamic uid){
  if(uid.runtimeType == String && uid.toString().length > 0 && uid.toString().length <= 128){

  }
}


bool? isTopic(dynamic topic) {
  if (topic.runtimeType != String) {
    return false;
  }
}
