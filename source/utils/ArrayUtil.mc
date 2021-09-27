class ArrayUtil {
  static function sorted(arr, compareCallback) { 
    var array = arr.slice(null, null);
    var done = false; 
    while (!done) { 
      done = true; 
      for (var i = 1; i < array.size(); i += 1) { 
        if (compareCallback.invoke(array[i - 1], array[i])) { 
          done = false; 
          var tmp = array[i - 1]; 
          array[i - 1] = array[i]; 
          array[i] = tmp; 
        } 
      } 
    } 
    return array; 
  } 
}