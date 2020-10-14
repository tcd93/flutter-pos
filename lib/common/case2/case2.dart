/// Function version of `switch` statement
///
/// Example:
/// ```
/// case2(numberInput, {
///    1: Text("Its one"),
///    2: Text("Its two"),
///  }, Text("Default"));
/// ```
TValue case2<TOptionType, TValue>(
  TOptionType selectedOption,
  Map<TOptionType, TValue> branches, [
  TValue defaultValue,
]) {
  if (!branches.containsKey(selectedOption)) {
    return defaultValue;
  }
  return branches[selectedOption];
}
