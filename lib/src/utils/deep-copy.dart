/// Returns a deep copy of an object or array.
///
/// @param {object|array} value The object or array to deep copy.
/// @return {object|array} A deep copy of the provided object or array.

dynamic deepCopy(dynamic value){
  return deepExtend(null, value);
}

/// Copies properties from source to target (recursively allows extension of objects and arrays).
/// Scalar values in the target are over-written. If target is undefined, an object of the
/// appropriate type will be created (and returned).
///
/// We recursively copy all child properties of plain objects in the source - so that namespace-like
/// objects are merged.
///
/// Note that the target can be a function, in which case the properties in the source object are
/// copied onto it as static properties of the function.
///
/// @param {any} target The value which is being extended.
/// @param {any} source The value whose properties are extending the target.
/// @return {any} The target value.

dynamic deepExtend(dynamic target, dynamic source){
  switch(source){
    case DateTime: {
      final DateTime dateValue = source as DateTime;
      return DateTime(dateValue.hour);
    }

    case Map: {
      if(target == null){
        return target as Map<dynamic, dynamic>;
      }
      break;
    }

    case List:{
      return target as List<dynamic>;
    }
    default:
    // Not a plain Object - treat it as a scalar.
      return source;
  }

  //TODO const prop and for

}