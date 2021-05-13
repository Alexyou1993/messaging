import 'dart:core';

/// Validates that a value is a byte buffer.
///
/// @param {dynamic} value The value to validate.
/// @return {boolean} Whether the value is byte buffer or not.

bool isBuffer(dynamic value) {
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

bool isList(dynamic value){
  if(value.runtimeType != List){
    return false;
  }
  return true;
}


/// Validates that a value is a non-empty array.
///
/// @param {dynamic} value The value to validate.
/// @return {boolean} Whether the value is a non-empty List or not.

bool isNonEmptyList(dynamic value){
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

bool isBoolean(dynamic value){
  if(value.runtimeType != bool){
    return false;
  }
  return true;
}



/// Validates that a value is a string.
///
/// @param {dynamic} value The value to validate.
/// @return {boolean} Whether the value is a string or not.

bool isString(dynamic value){
  if(value.runtimeType != String){
    return false;
  }
  return true;
}

/// Validates that a value is a base64 string.
///
/// @param {dynamic} value The value to validate.
/// @return {boolean} Whether the value is a base64 string or not.

bool isBase64String(dynamic value) {

}

/// Validates that a value is a non-empty string.
///
/// @param {dynamic} value The value to validate.
/// @return {boolean} Whether the value is a non-empty string or not.

bool isNonEmptyString(dynamic value){
  if(value.toString().isEmpty){
    return false;
  }
  return true;
}

/// Validates that a string is a valid Firebase Auth uid.
///
/// @param {dynamic} uid The string to validate.
/// @return {boolean} Whether the string is a valid Firebase Auth uid.

bool isUid(dynamic uid){
  if(uid.runtimeType == String && uid.toString().isNotEmpty && uid.toString().length <= 128){
    return true;
  }
  return false;
}

/// Validates that a string is a valid Firebase Auth password.
///
/// @param {any} password The password string to validate.
/// @return {boolean} Whether the string is a valid Firebase Auth password.

bool isPassword(dynamic password){
  // A password must be a string of at least 6 characters.
  if(password.runtimeType == String && password.toString().length >= 6){
    return true;
  }
  return false;
}

/// Validates that a string is a valid email.
///
/// @param {any} email The string to validate.
/// @return {boolean} Whether the string is valid email or not.

bool isEmail(dynamic email){
  if(email.runtimeType != String){
    return false;
  }
  // There must at least one character before the @ symbol and another after.
  if(email.toString().contains('@') && email.toString().length > 3){
    return true;
  }
  return false;
}

/// Validates that a string is a valid phone number.
/// @param {any} phoneNumber The string to validate.
/// @return {boolean} Whether the string is a valid phone number or not.

bool isPhoneNumber(dynamic phoneNumber) {
  if(phoneNumber.runtimeType != String){
    return false;
  }
  // Phone number validation is very lax here. Backend will enforce E.164
  // spec compliance and will normalize accordingly.
  // The phone number string must be non-empty and starts with a plus sign.
  // The phone number string must contain at least one alphanumeric character.
  final  RegExp validCharacters = RegExp(r'^[a-zA-Z]+$');
  if(phoneNumber.toString().contains('+') && phoneNumber.toString().contains(validCharacters) && phoneNumber.toString().isNotEmpty){
      return true;
  }
  return false;
}

/// Validates that a string is a valid ISO date string.
///
/// @param dateString The string to validate.
/// @return Whether the string is a valid ISO date string.

bool isISODateString(dynamic dateString){
  if(dateString.toString().isNotEmpty && dateString.runtimeType == DateTime(dateString as int).toIso8601String().runtimeType){
    return true;
  }
  return false;
}

/// Validates that a string is a valid UTC date string.
///
/// @param dateString The string to validate.
/// @return Whether the string is a valid UTC date string.

bool isUTCDateString(dynamic dateString){
  if(dateString.toString().isNotEmpty && dateString.runtimeType == DateTime(dateString as int).toUtc().runtimeType){
    return true;
  }
  return false;
}

/// Validates that a string is a valid web URL.
///
/// @param {dynamic} urlStr The string to validate.
/// @return {boolean} Whether the string is valid web URL or not.

bool isUrl(dynamic urlStr){
  if(urlStr != String) {
    return false;
  }
  // Lookup illegal characters.
  final  RegExp illegalCharacters = RegExp(r'^[a-z0-9:/?#[\]@!$&()*+,;=.\-_~%]');
  if(urlStr.toString().contains(illegalCharacters)){
    return false;
  }

  final Uri uri = urlStr as Uri;
  final String scheme = uri.scheme;
  final String hostname = uri.host;
  final String pathname = uri.path;
}



bool isTopic(dynamic topic) {
  if (topic.runtimeType != String) {
    return false;
  }
  return true;
}
