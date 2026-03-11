# Dart Extensions Challenges (80 exercises)

## Level 1 - Very Easy (15 exercises)

### Exercise 1: Minutes to Movie Length

**Time**: 5 min | **Difficulty**: 1

**Description**: Create an extension on `int` that converts minutes to a movie length format (hours and minutes).

**Examples**:
```dart
60.toMovieLength()     // '1h'
80.toMovieLength()     // '1h 20min'
120.toMovieLength()    // '2h'
145.toMovieLength()    // '2h 25min'
5.toMovieLength()      // '5min'
```

**Starter Code**:
```dart
extension MovieLengthExtension on int {
  // TODO: Implement toMovieLength() method
}

void main() {
  print(60.toMovieLength());   // Expected: '1h'
  print(80.toMovieLength());   // Expected: '1h 20min'
  print(145.toMovieLength());  // Expected: '2h 25min'
}
```

**Solution**: See `solutions/01-movie-length.dart`

---

### Exercise 2: String Word Count

**Time**: 5 min | **Difficulty**: 1

**Description**: Create an extension on `String` that counts the number of words.

**Examples**:
```dart
'Hello world'.wordCount           // 2
'One'.wordCount                   // 1
'  Multiple   spaces  '.wordCount // 2
''.wordCount                      // 0
```

**Starter Code**:
```dart
extension WordCountExtension on String {
  // TODO: Implement wordCount getter
}
```

---

### Exercise 3: List First and Last

**Time**: 5 min | **Difficulty**: 1

**Description**: Create extensions on `List<T>` to get first and last elements safely.

**Examples**:
```dart
[1, 2, 3].firstSafe    // 1
[].firstSafe           // null
[5].lastSafe           // 5
[].lastSafe            // null
```

**Starter Code**:
```dart
extension ListSafeAccess<T> on List<T> {
  // TODO: Implement firstSafe getter
  // TODO: Implement lastSafe getter
}
```

---

### Exercise 4: String Is Empty

**Time**: 5 min | **Difficulty**: 1

**Description**: Create an extension on `String?` to check if string is null, empty, or only whitespace.

**Examples**:
```dart
null.isEmptyOrBlank        // true
''.isEmptyOrBlank          // true
'   '.isEmptyOrBlank       // true
'hello'.isEmptyOrBlank     // false
```

**Starter Code**:
```dart
extension StringNullCheck on String? {
  // TODO: Implement isEmptyOrBlank getter
}
```

---

### Exercise 5: Int Repeat String

**Time**: 5 min | **Difficulty**: 1

**Description**: Create an extension on `int` to repeat a string N times.

**Examples**:
```dart
3.times('ab')      // 'ababab'
0.times('x')       // ''
1.times('hello')   // 'hello'
```

**Starter Code**:
```dart
extension IntRepeat on int {
  // TODO: Implement times(String) method
}
```

---

### Exercise 6: Map Safe Get

**Time**: 5 min | **Difficulty**: 1

**Description**: Create an extension on `Map<K, V>` to safely get values with default.

**Examples**:
```dart
{'a': 1}.getOr('a', 0)     // 1
{'a': 1}.getOr('b', 0)     // 0
{}.getOr('x', 'def')       // 'def'
```

**Starter Code**:
```dart
extension MapSafeGet<K, V> on Map<K, V> {
  // TODO: Implement getOr(K key, V defaultValue) method
}
```

---

### Exercise 7: String Truncate

**Time**: 5 min | **Difficulty**: 1

**Description**: Create an extension on `String` to truncate to max length with optional suffix.

**Examples**:
```dart
'Hello World'.truncate(5)           // 'Hello...'
'Hi'.truncate(10)                   // 'Hi'
'Hello World'.truncate(5, '')       // 'Hello'
```

**Starter Code**:
```dart
extension StringTruncate on String {
  // TODO: Implement truncate(int maxLength, {String suffix}) method
}
```

---

### Exercise 8: List Chunk

**Time**: 10 min | **Difficulty**: 2

**Description**: Create an extension on `List<T>` to split into chunks of given size.

**Examples**:
```dart
[1, 2, 3, 4, 5].chunk(2)  // [[1, 2], [3, 4], [5]]
[1, 2, 3].chunk(3)        // [[1, 2, 3]]
[1, 2].chunk(5)           // [[1, 2]]
[].chunk(2)               // []
```

**Starter Code**:
```dart
extension ListChunk<T> on List<T> {
  // TODO: Implement chunk(int size) method
}
```

---

### Exercise 9: DateTime Is Today

**Time**: 5 min | **Difficulty**: 1

**Description**: Create an extension on `DateTime` to check if it's today.

**Examples**:
```dart
DateTime.now().isToday      // true
DateTime(2020, 1, 1).isToday // false
```

**Starter Code**:
```dart
extension DateTimeToday on DateTime {
  // TODO: Implement isToday getter
}
```

---

### Exercise 10: String To Int

**Time**: 5 min | **Difficulty**: 1

**Description**: Create an extension on `String` to safely parse to int.

**Examples**:
```dart
'123'.toIntOrNull()     // 123
'abc'.toIntOrNull()     // null
'-45'.toIntOrNull()     // -45
```

**Starter Code**:
```dart
extension StringToInt on String {
  // TODO: Implement toIntOrNull() method
}
```

---

### Exercise 11: Bool To Int

**Time**: 5 min | **Difficulty**: 1

**Description**: Create an extension on `bool` to convert to 1/0.

**Examples**:
```dart
true.toInt()    // 1
false.toInt()   // 0
```

**Starter Code**:
```dart
extension BoolToInt on bool {
  // TODO: Implement toInt() method
}
```

---

### Exercise 12: List Without Nulls

**Time**: 5 min | **Difficulty**: 1

**Description**: Create an extension on `List<T?>` to remove null values.

**Examples**:
```dart
[1, null, 2, null, 3].withoutNulls  // [1, 2, 3]
[].withoutNulls                      // []
[null, null].withoutNulls            // []
```

**Starter Code**:
```dart
extension ListWithoutNulls<T> on List<T?> {
  // TODO: Implement withoutNulls getter
}
```

---

### Exercise 13: String Capitalize

**Time**: 5 min | **Difficulty**: 1

**Description**: Create an extension on `String` to capitalize first letter.

**Examples**:
```dart
'hello'.capitalize    // 'Hello'
'HELLO'.capitalize    // 'Hello'
''.capitalize         // ''
```

**Starter Code**:
```dart
extension StringCapitalize on String {
  // TODO: Implement capitalize() method
}
```

---

### Exercise 14: Map Invert

**Time**: 10 min | **Difficulty**: 2

**Description**: Create an extension on `Map<K, V>` to invert keys and values.

**Examples**:
```dart
{'a': 1, 'b': 2}.invert    // {1: 'a', 2: 'b'}
{}.invert                   // {}
```

**Starter Code**:
```dart
extension MapInvert<K, V> on Map<K, V> {
  // TODO: Implement invert() method
}
```

---

### Exercise 15: Int Is Even/Odd

**Time**: 5 min | **Difficulty**: 1

**Description**: Create extensions on `int` to check if even or odd.

**Examples**:
```dart
4.isEven    // true
7.isOdd     // true
0.isEven    // true
```

**Starter Code**:
```dart
extension IntParity on int {
  // TODO: Implement isEven getter
  // TODO: Implement isOdd getter
}
```

---

## Level 2 - Easy (20 exercises)

### Exercise 16: String Camel Case

**Time**: 10 min | **Difficulty**: 2

**Description**: Convert string to camelCase.

**Examples**:
```dart
'hello world'.toCamelCase()      // 'helloWorld'
'Hello World'.toCamelCase()      // 'helloWorld'
'hello-world'.toCamelCase()      // 'helloWorld'
'hello_world'.toCamelCase()      // 'helloWorld'
```

**Starter Code**:
```dart
extension StringCamelCase on String {
  // TODO: Implement toCamelCase() method
}
```

---

### Exercise 17: List Flatten

**Time**: 10 min | **Difficulty**: 2

**Description**: Flatten a nested list one level deep.

**Examples**:
```dart
[[1, 2], [3, 4], [5]].flatten()    // [1, 2, 3, 4, 5]
[[1], [], [2, 3]].flatten()        // [1, 2, 3]
[1, 2, 3].flatten()                // [1, 2, 3] (already flat)
```

**Starter Code**:
```dart
extension ListFlatten<T> on List<List<T>> {
  // TODO: Implement flatten() method
}
```

---

### Exercise 18: DateTime Age

**Time**: 10 min | **Difficulty**: 2

**Description**: Calculate age from birth date.

**Examples**:
```dart
DateTime(2000, 1, 1).age    // 26 (in 2026)
```

**Starter Code**:
```dart
extension DateTimeAge on DateTime {
  // TODO: Implement age getter
}
```

---

### Exercise 19: String Is Palindrome

**Time**: 10 min | **Difficulty**: 2

**Description**: Check if string is palindrome (case insensitive, ignoring spaces).

**Examples**:
```dart
'radar'.isPalindrome           // true
'A man a plan a canal Panama'.isPalindrome  // true
'hello'.isPalindrome           // false
```

**Starter Code**:
```dart
extension StringPalindrome on String {
  // TODO: Implement isPalindrome getter
}
```

---

### Exercise 20: List Zip

**Time**: 10 min | **Difficulty**: 2

**Description**: Zip two lists together into pairs.

**Examples**:
```dart
[1, 2, 3].zip([4, 5, 6])    // [(1,4), (2,5), (3,6)]
[1, 2].zip([3, 4, 5, 6])    // [(1,3), (2,4)] (shortest wins)
[].zip([1, 2])              // []
```

**Starter Code**:
```dart
extension ListZip<T> on List<T> {
  // TODO: Implement zip<U>(List<U> other) method
}
```

---

### Exercise 21: Map Group By

**Time**: 10 min | **Difficulty**: 2

**Description**: Group list elements by a selector function.

**Examples**:
```dart
['a', 'bb', 'ccc'].groupBy((s) => s.length)
// {1: ['a'], 2: ['bb'], 3: ['ccc']}

[1, 2, 3, 4].groupBy((n) => n.isEven ? 'even' : 'odd')
// {'odd': [1, 3], 'even': [2, 4]}
```

**Starter Code**:
```dart
extension ListGroupBy<T> on List<T> {
  // TODO: Implement groupBy<K>(K Function(T) selector) method
}
```

---

### Exercise 22: String Strip HTML

**Time**: 10 min | **Difficulty**: 2

**Description**: Remove HTML tags from string.

**Examples**:
```dart
'<p>Hello <b>World</b></p>'.stripHtml()  // 'Hello World'
'<div>Test</div>'.stripHtml()            // 'Test'
```

**Starter Code**:
```dart
extension StringStripHtml on String {
  // TODO: Implement stripHtml() method
}
```

---

### Exercise 23: Int Clamp

**Time**: 5 min | **Difficulty**: 2

**Description**: Clamp int between min and max values.

**Examples**:
```dart
5.clamp(0, 10)     // 5
15.clamp(0, 10)    // 10
-5.clamp(0, 10)    // 0
```

**Starter Code**:
```dart
extension IntClamp on int {
  // TODO: Implement clamp(int min, int max) method
}
```

---

### Exercise 24: List Rotate

**Time**: 10 min | **Difficulty**: 2

**Description**: Rotate list by N positions.

**Examples**:
```dart
[1, 2, 3, 4, 5].rotate(2)   // [4, 5, 1, 2, 3]
[1, 2, 3].rotate(-1)        // [2, 3, 1]
[1, 2, 3].rotate(0)         // [1, 2, 3]
```

**Starter Code**:
```dart
extension ListRotate<T> on List<T> {
  // TODO: Implement rotate(int positions) method
}
```

---

### Exercise 25: String To Title Case

**Time**: 10 min | **Difficulty**: 2

**Description**: Convert string to Title Case.

**Examples**:
```dart
'hello world'.toTitleCase()      // 'Hello World'
'HELLO WORLD'.toTitleCase()      // 'Hello World'
```

**Starter Code**:
```dart
extension StringTitleCase on String {
  // TODO: Implement toTitleCase() method
}
```

---

### Exercise 26: Map Merge

**Time**: 10 min | **Difficulty**: 2

**Description**: Merge two maps, with conflict resolver.

**Examples**:
```dart
{'a': 1, 'b': 2}.merge({'b': 3, 'c': 4}, (v1, v2) => v1 + v2)
// {'a': 1, 'b': 5, 'c': 4}
```

**Starter Code**:
```dart
extension MapMerge<K, V> on Map<K, V> {
  // TODO: Implement merge(Map<K, V> other, V Function(V, V) resolver) method
}
```

---

### Exercise 27: List Unique

**Time**: 10 min | **Difficulty**: 2

**Description**: Get unique elements from list.

**Examples**:
```dart
[1, 2, 2, 3, 1, 4].unique    // [1, 2, 3, 4]
['a', 'b', 'a'].unique       // ['a', 'b']
```

**Starter Code**:
```dart
extension ListUnique<T> on List<T> {
  // TODO: Implement unique getter
}
```

---

### Exercise 28: DateTime Is Leap Year

**Time**: 10 min | **Difficulty**: 2

**Description**: Check if year is leap year.

**Examples**:
```dart
DateTime(2024, 1, 1).isLeapYear    // true
DateTime(2023, 1, 1).isLeapYear    // false
DateTime(2000, 1, 1).isLeapYear    // true
DateTime(1900, 1, 1).isLeapYear    // false
```

**Starter Code**:
```dart
extension DateTimeLeapYear on DateTime {
  // TODO: Implement isLeapYear getter
}
```

---

### Exercise 29: String Count Characters

**Time**: 10 min | **Difficulty**: 2

**Description**: Count occurrences of each character.

**Examples**:
```dart
'hello'.countChars    // {'h': 1, 'e': 1, 'l': 2, 'o': 1}
```

**Starter Code**:
```dart
extension StringCountChars on String {
  // TODO: Implement countChars getter
}
```

---

### Exercise 30: List Intersection

**Time**: 10 min | **Difficulty**: 2

**Description**: Get intersection of two lists.

**Examples**:
```dart
[1, 2, 3, 4].intersection([3, 4, 5, 6])  // [3, 4]
[1, 2].intersection([3, 4])              // []
```

**Starter Code**:
```dart
extension ListIntersection<T> on List<T> {
  // TODO: Implement intersection(List<T> other) method
}
```

---

### Exercise 31: Int To Binary/Hex

**Time**: 10 min | **Difficulty**: 2

**Description**: Convert int to binary or hex string.

**Examples**:
```dart
10.toBinary()    // '1010'
255.toHex()      // 'ff'
16.toHex()       // '10'
```

**Starter Code**:
```dart
extension IntBaseConvert on int {
  // TODO: Implement toBinary() method
  // TODO: Implement toHex() method
}
```

---

### Exercise 32: String Reverse

**Time**: 5 min | **Difficulty**: 2

**Description**: Reverse a string.

**Examples**:
```dart
'hello'.reverse    // 'olleh'
'12345'.reverse    // '54321'
```

**Starter Code**:
```dart
extension StringReverse on String {
  // TODO: Implement reverse getter
}
```

---

### Exercise 33: List Difference

**Time**: 10 min | **Difficulty**: 2

**Description**: Get elements in first list but not in second.

**Examples**:
```dart
[1, 2, 3, 4].difference([3, 4, 5])  // [1, 2]
```

**Starter Code**:
```dart
extension ListDifference<T> on List<T> {
  // TODO: Implement difference(List<T> other) method
}
```

---

### Exercise 34: Map Filter Keys

**Time**: 10 min | **Difficulty**: 2

**Description**: Filter map by keys.

**Examples**:
```dart
{'a': 1, 'b': 2, 'c': 3}.filterKeys(['a', 'c'])
// {'a': 1, 'c': 3}
```

**Starter Code**:
```dart
extension MapFilterKeys<K, V> on Map<K, V> {
  // TODO: Implement filterKeys(Iterable<K> keys) method
}
```

---

### Exercise 35: DateTime Days In Month

**Time**: 10 min | **Difficulty**: 2

**Description**: Get number of days in month.

**Examples**:
```dart
DateTime(2024, 2, 1).daysInMonth    // 29 (leap year)
DateTime(2023, 2, 1).daysInMonth    // 28
DateTime(2024, 1, 1).daysInMonth    // 31
```

**Starter Code**:
```dart
extension DateTimeDaysInMonth on DateTime {
  // TODO: Implement daysInMonth getter
}
```

---

## Level 3 - Intermediate (20 exercises)

### Exercise 36: String Levenshtein Distance

**Time**: 15 min | **Difficulty**: 3

**Description**: Calculate Levenshtein distance between two strings.

**Examples**:
```dart
'kitten'.levenshteinTo('sitting')    // 3
'saturday'.levenshteinTo('sunday')   // 3
```

**Starter Code**:
```dart
extension StringLevenshtein on String {
  // TODO: Implement levenshteinTo(String other) method
}
```

---

### Exercise 36: List Permutations

**Time**: 15 min | **Difficulty**: 3

**Description**: Generate all permutations of a list.

**Examples**:
```dart
[1, 2, 3].permutations
// [[1,2,3], [1,3,2], [2,1,3], [2,3,1], [3,1,2], [3,2,1]]
```

**Starter Code**:
```dart
extension ListPermutations<T> on List<T> {
  // TODO: Implement permutations getter
}
```

---

### Exercise 38: Map Deep Clone

**Time**: 15 min | **Difficulty**: 3

**Description**: Deep clone a nested map.

**Examples**:
```dart
{'a': {'b': {'c': 1}}}.deepClone()
```

**Starter Code**:
```dart
extension MapDeepClone<K, V> on Map<K, V> {
  // TODO: Implement deepClone() method
}
```

---

### Exercise 39: String Run Length Encode

**Time**: 15 min | **Difficulty**: 3

**Description**: Encode string using run-length encoding.

**Examples**:
```dart
'aaabbcccc'.runLengthEncode    // '3a2b4c'
'abc'.runLengthEncode          // '1a1b1c'
```

**Starter Code**:
```dart
extension StringRunLengthEncode on String {
  // TODO: Implement runLengthEncode getter
}
```

---

### Exercise 40: List Binary Search

**Time**: 15 min | **Difficulty**: 3

**Description**: Implement binary search on sorted list.

**Examples**:
```dart
[1, 3, 5, 7, 9].binarySearch(5)    // 2
[1, 3, 5, 7, 9].binarySearch(4)    // -1
```

**Starter Code**:
```dart
extension ListBinarySearch<T extends Comparable<T>> on List<T> {
  // TODO: Implement binarySearch(T target) method
}
```

---

### Exercise 41: DateTime Business Days Between

**Time**: 15 min | **Difficulty**: 3

**Description**: Count business days between two dates.

**Examples**:
```dart
DateTime(2024, 1, 1).businessDaysTo(DateTime(2024, 1, 15))
// Excludes weekends
```

**Starter Code**:
```dart
extension DateTimeBusinessDays on DateTime {
  // TODO: Implement businessDaysTo(DateTime end) method
}
```

---

### Exercise 42: String To Snake Case

**Time**: 15 min | **Difficulty**: 3

**Description**: Convert string to snake_case.

**Examples**:
```dart
'helloWorld'.toSnakeCase()      // 'hello_world'
'HelloWorld'.toSnakeCase()      // 'hello_world'
'hello-world'.toSnakeCase()     // 'hello_world'
```

**Starter Code**:
```dart
extension StringSnakeCase on String {
  // TODO: Implement toSnakeCase() method
}
```

---

### Exercise 43: List Move Element

**Time**: 15 min | **Difficulty**: 3

**Description**: Move element from one index to another.

**Examples**:
```dart
[1, 2, 3, 4, 5].move(0, 3)    // [2, 3, 4, 1, 5]
[1, 2, 3].move(2, 0)          // [3, 1, 2]
```

**Starter Code**:
```dart
extension ListMove<T> on List<T> {
  // TODO: Implement move(int from, int to) method
}
```

---

### Exercise 44: Map Flatten

**Time**: 15 min | **Difficulty**: 3

**Description**: Flatten nested map with dot notation keys.

**Examples**:
```dart
{'a': {'b': 1, 'c': {'d': 2}}}.flatten()
// {'a.b': 1, 'a.c.d': 2}
```

**Starter Code**:
```dart
extension MapFlatten on Map<String, dynamic> {
  // TODO: Implement flatten() method
}
```

---

### Exercise 45: Int Next Prime

**Time**: 15 min | **Difficulty**: 3

**Description**: Find next prime number after given int.

**Examples**:
```dart
10.nextPrime    // 11
14.nextPrime    // 17
1.nextPrime     // 2
```

**Starter Code**:
```dart
extension IntNextPrime on int {
  // TODO: Implement nextPrime getter
}
```

---

### Exercise 46: String Is Anagram

**Time**: 15 min | **Difficulty**: 3

**Description**: Check if two strings are anagrams.

**Examples**:
```dart
'listen'.isAnagramOf('silent')      // true
'hello'.isAnagramOf('world')        // false
```

**Starter Code**:
```dart
extension StringAnagram on String {
  // TODO: Implement isAnagramOf(String other) method
}
```

---

### Exercise 47: List Sliding Window

**Time**: 15 min | **Difficulty**: 3

**Description**: Create sliding windows over list.

**Examples**:
```dart
[1, 2, 3, 4, 5].sliding(3)
// [[1,2,3], [2,3,4], [3,4,5]]
```

**Starter Code**:
```dart
extension ListSlidingWindow<T> on List<T> {
  // TODO: Implement sliding(int size) method
}
```

---

### Exercise 48: DateTime Add Business Days

**Time**: 15 min | **Difficulty**: 3

**Description**: Add business days to date (skip weekends).

**Examples**:
```dart
DateTime(2024, 1, 5).addBusinessDays(5)
// Friday + 5 business days = Friday (next week)
```

**Starter Code**:
```dart
extension DateTimeAddBusinessDays on DateTime {
  // TODO: Implement addBusinessDays(int days) method
}
```

---

### Exercise 49: Map Partition

**Time**: 15 min | **Difficulty**: 3

**Description**: Partition map into two maps based on predicate.

**Examples**:
```dart
{'a': 1, 'b': 2, 'c': 3}.partition((k, v) => v.isEven)
// ({'b': 2}, {'a': 1, 'c': 3})
```

**Starter Code**:
```dart
extension MapPartition<K, V> on Map<K, V> {
  // TODO: Implement partition(bool Function(K, V) predicate) method
}
```

---

### Exercise 50: String Parse JSON Path

**Time**: 15 min | **Difficulty**: 3

**Description**: Extract value from JSON string using path.

**Examples**:
```dart
'{"a":{"b":1}}'.jsonPath('a.b')    // 1
```

**Starter Code**:
```dart
extension StringJsonPath on String {
  // TODO: Implement jsonPath(String path) method
}
```

---

### Exercise 51: List Cartesian Product

**Time**: 15 min | **Difficulty**: 3

**Description**: Calculate cartesian product of two lists.

**Examples**:
```dart
[1, 2].cartesian([3, 4])
// [(1,3), (1,4), (2,3), (2,4)]
```

**Starter Code**:
```dart
extension ListCartesian<T> on List<T> {
  // TODO: Implement cartesian<U>(List<U> other) method
}
```

---

### Exercise 52: Int GCD/LCM

**Time**: 15 min | **Difficulty**: 3

**Description**: Calculate GCD and LCM of two numbers.

**Examples**:
```dart
12.gcd(18)    // 6
12.lcm(18)    // 36
```

**Starter Code**:
```dart
extension IntGcdLcm on int {
  // TODO: Implement gcd(int other) method
  // TODO: Implement lcm(int other) method
}
```

---

### Exercise 53: String Compress

**Time**: 15 min | **Difficulty**: 3

**Description**: Compress string by replacing repeated chars.

**Examples**:
```dart
'aaabbbcccc'.compress()    // 'a3b3c4'
'abc'.compress()           // 'abc' (no compression if not shorter)
```

**Starter Code**:
```dart
extension StringCompress on String {
  // TODO: Implement compress() method
}
```

---

### Exercise 54: List Shuffle Deterministic

**Time**: 15 min | **Difficulty**: 3

**Description**: Shuffle list with seed for reproducibility.

**Examples**:
```dart
[1, 2, 3, 4, 5].shuffledWithSeed(42)
// Same result every time with seed 42
```

**Starter Code**:
```dart
extension ListShuffleSeed<T> on List<T> {
  // TODO: Implement shuffledWithSeed(int seed) method
}
```

---

### Exercise 55: Map Deep Merge

**Time**: 15 min | **Difficulty**: 3

**Description**: Deep merge two nested maps.

**Examples**:
```dart
{'a': {'b': 1}}.deepMerge({'a': {'c': 2}})
// {'a': {'b': 1, 'c': 2}}
```

**Starter Code**:
```dart
extension MapDeepMerge<K, V> on Map<K, V> {
  // TODO: Implement deepMerge(Map<K, dynamic> other) method
}
```

---

## Level 4 - Hard (15 exercises)

### Exercise 56: String Template Replace

**Time**: 20 min | **Difficulty**: 4

**Description**: Replace template placeholders with values.

**Examples**:
```dart
'Hello, {{name}}!'.templateReplace({'name': 'World'})
// 'Hello, World!'
```

**Starter Code**:
```dart
extension StringTemplateReplace on String {
  // TODO: Implement templateReplace(Map<String, String> values) method
}
```

---

### Exercise 57: List Quick Select

**Time**: 20 min | **Difficulty**: 4

**Description**: Find kth smallest element using quickselect.

**Examples**:
```dart
[7, 10, 4, 3, 20, 15].quickSelect(3)    // 7 (3rd smallest)
```

**Starter Code**:
```dart
extension ListQuickSelect<T extends Comparable<T>> on List<T> {
  // TODO: Implement quickSelect(int k) method
}
```

---

### Exercise 58: Map LRU Cache

**Time**: 20 min | **Difficulty**: 4

**Description**: Implement LRU cache using map.

**Examples**:
```dart
final cache = LRUCache<String, int>(capacity: 2);
cache.put('a', 1);
cache.put('b', 2);
cache.put('c', 3);  // evicts 'a'
cache.get('b');     // 2
```

**Starter Code**:
```dart
class LRUCache<K, V> {
  // TODO: Implement
}
```

---

### Exercise 59: String Bracket Validate

**Time**: 20 min | **Difficulty**: 4

**Description**: Validate balanced brackets.

**Examples**:
```dart
'()[]{}'.isValidBrackets     // true
'([)]'.isValidBrackets       // false
'{[]}'.isValidBrackets       // true
```

**Starter Code**:
```dart
extension StringBracketValidate on String {
  // TODO: Implement isValidBrackets getter
}
```

---

### Exercise 60: List Merge Sorted

**Time**: 20 min | **Difficulty**: 4

**Description**: Merge two sorted lists.

**Examples**:
```dart
[1, 3, 5].mergeSorted([2, 4, 6])    // [1, 2, 3, 4, 5, 6]
```

**Starter Code**:
```dart
extension ListMergeSorted<T extends Comparable<T>> on List<T> {
  // TODO: Implement mergeSorted(List<T> other) method
}
```

---

### Exercise 61: DateTime Relative Time

**Time**: 20 min | **Difficulty**: 4

**Description**: Format relative time string.

**Examples**:
```dart
DateTime.now().subtract(Duration(minutes: 5)).relativeTime
// '5 minutes ago'
DateTime.now().add(Duration(days: 2)).relativeTime
// 'in 2 days'
```

**Starter Code**:
```dart
extension DateTimeRelativeTime on DateTime {
  // TODO: Implement relativeTime getter
}
```

---

### Exercise 62: Map Topological Sort

**Time**: 20 min | **Difficulty**: 4

**Description**: Topological sort of dependency graph.

**Examples**:
```dart
{
  'a': ['c'],
  'b': ['c'],
  'c': []
}.topologicalSort()
// ['c', 'a', 'b'] or ['c', 'b', 'a']
```

**Starter Code**:
```dart
extension MapTopologicalSort<K> on Map<K, List<K>> {
  // TODO: Implement topologicalSort() method
}
```

---

### Exercise 63: String Generate Permutations

**Time**: 20 min | **Difficulty**: 4

**Description**: Generate all string permutations.

**Examples**:
```dart
'abc'.permutations
// ['abc', 'acb', 'bac', 'bca', 'cab', 'cba']
```

**Starter Code**:
```dart
extension StringPermutations on String {
  // TODO: Implement permutations getter
}
```

---

### Exercise 64: List Segment Tree

**Time**: 25 min | **Difficulty**: 4

**Description**: Build segment tree for range queries.

**Examples**:
```dart
final tree = SegmentTree([1, 3, 5, 7, 9]);
tree.query(1, 3)    // 15 (sum of elements 1-3)
```

**Starter Code**:
```dart
class SegmentTree {
  // TODO: Implement
}
```

---

### Exercise 65: Int Factorial Trailing Zeros

**Time**: 20 min | **Difficulty**: 4

**Description**: Count trailing zeros in factorial.

**Examples**:
```dart
25.trailingZerosInFactorial    // 6
```

**Starter Code**:
```dart
extension IntFactorialZeros on int {
  // TODO: Implement trailingZerosInFactorial getter
}
```

---

### Exercise 66: String Regex Match

**Time**: 20 min | **Difficulty**: 4

**Description**: Simple regex matcher for ., *, +.

**Examples**:
```dart
'abc'.regexMatch('a.c')       // true
'abc'.regexMatch('a.*')       // true
'aaa'.regexMatch('a+')        // true
```

**Starter Code**:
```dart
extension StringRegexMatch on String {
  // TODO: Implement regexMatch(String pattern) method
}
```

---

### Exercise 67: Map Trie Operations

**Time**: 20 min | **Difficulty**: 4

**Description**: Implement trie with map.

**Examples**:
```dart
final trie = Trie();
trie.insert('apple');
trie.search('apple')     // true
trie.startsWith('app')   // true
```

**Starter Code**:
```dart
class Trie {
  // TODO: Implement
}
```

---

### Exercise 68: List Dutch Flag

**Time**: 20 min | **Difficulty**: 4

**Description**: Sort 0s, 1s, 2s in one pass.

**Examples**:
```dart
[2, 0, 1, 2, 0, 1].dutchFlagSort    // [0, 0, 1, 1, 2, 2]
```

**Starter Code**:
```dart
extension ListDutchFlag on List<int> {
  // TODO: Implement dutchFlagSort getter
}
```

---

### Exercise 69: DateTime Week Number

**Time**: 20 min | **Difficulty**: 4

**Description**: Get ISO week number.

**Examples**:
```dart
DateTime(2024, 1, 1).weekNumber    // 1
DateTime(2024, 12, 30).weekNumber  // 1 (next year)
```

**Starter Code**:
```dart
extension DateTimeWeekNumber on DateTime {
  // TODO: Implement weekNumber getter
}
```

---

### Exercise 70: String Longest Palindrome

**Time**: 25 min | **Difficulty**: 4

**Description**: Find longest palindromic substring.

**Examples**:
```dart
'babad'.longestPalindrome    // 'bab' or 'aba'
'cbbd'.longestPalindrome     // 'bb'
```

**Starter Code**:
```dart
extension StringLongestPalindrome on String {
  // TODO: Implement longestPalindrome getter
}
```

---

## Level 5 - Very Hard (10 exercises)

### Exercise 71: String KMP Search

**Time**: 30 min | **Difficulty**: 5

**Description**: Implement Knuth-Morris-Pratt string search.

**Examples**:
```dart
'abcxabcdabcdxabcd'.kmpSearch('abcd')    // [4, 8, 12]
```

**Starter Code**:
```dart
extension StringKmpSearch on String {
  // TODO: Implement kmpSearch(String pattern) method
}
```

---

### Exercise 72: List Median Of Two Sorted

**Time**: 30 min | **Difficulty**: 5

**Description**: Find median of two sorted arrays.

**Examples**:
```dart
[1, 3].medianOfTwoSorted([2])           // 2.0
[1, 2].medianOfTwoSorted([3, 4])        // 2.5
```

**Starter Code**:
```dart
extension ListMedianOfTwoSorted on List<num> {
  // TODO: Implement medianOfTwoSorted(List<num> other) method
}
```

---

### Exercise 73: String Basic Calculator

**Time**: 30 min | **Difficulty**: 5

**Description**: Evaluate mathematical expression string.

**Examples**:
```dart
'3+2*2'.calculate()     // 7
' 3/2 '.calculate()     // 1
' 3+5 / 2 '.calculate() // 5
```

**Starter Code**:
```dart
extension StringCalculate on String {
  // TODO: Implement calculate() method
}
```

---

### Exercise 74: Map Serialize Deserialize

**Time**: 30 min | **Difficulty**: 5

**Description**: Serialize/deserialize nested map to compact string.

**Examples**:
```dart
final serialized = map.serialize();
final deserialized = serialized.deserialize();
```

**Starter Code**:
```dart
extension MapSerialize on Map<String, dynamic> {
  // TODO: Implement serialize() method
}

extension StringDeserialize on String {
  // TODO: Implement deserialize() method
}
```

---

### Exercise 75: List Trapping Rain Water

**Time**: 30 min | **Difficulty**: 5

**Description**: Calculate trapped rain water.

**Examples**:
```dart
[0,1,0,2,1,0,1,3,2,1,2,1].trapRain()    // 6
```

**Starter Code**:
```dart
extension ListTrapRain on List<int> {
  // TODO: Implement trapRain() method
}
```

---

### Exercise 76: String Regular Expression

**Time**: 30 min | **Difficulty**: 5

**Description**: Full regex engine with grouping.

**Examples**:
```dart
'(ab)+'.matches('abab')     // true
'a(b|c)d'.matches('abd')    // true
```

**Starter Code**:
```dart
class RegexMatcher {
  // TODO: Implement
}
```

---

### Exercise 77: List Sliding Window Maximum

**Time**: 30 min | **Difficulty**: 5

**Description**: Find max in each sliding window.

**Examples**:
```dart
[1,3,-1,-3,5,3,6,7].slidingMax(3)
// [3, 3, 5, 5, 6, 7]
```

**Starter Code**:
```dart
extension ListSlidingMax on List<int> {
  // TODO: Implement slidingMax(int k) method
}
```

---

### Exercise 78: Int Power Modular

**Time**: 30 min | **Difficulty**: 5

**Description**: Calculate (base^exp) % mod efficiently.

**Examples**:
```dart
2.modPow(10, 1000)    // 24
```

**Starter Code**:
```dart
extension IntModPow on int {
  // TODO: Implement modPow(int exp, int mod) method
}
```

---

### Exercise 79: String Edit Distance

**Time**: 30 min | **Difficulty**: 5

**Description**: Calculate minimum edit distance with operations.

**Examples**:
```dart
'horse'.editDistanceTo('ros')    // 3
```

**Starter Code**:
```dart
extension StringEditDistance on String {
  // TODO: Implement editDistanceTo(String other) method
}
```

---

### Exercise 80: List N-Queens Solver

**Time**: 30 min | **Difficulty**: 5

**Description**: Solve N-Queens problem.

**Examples**:
```dart
4.nQueensSolutions    // 2 (number of solutions)
```

**Starter Code**:
```dart
extension NQueens on int {
  // TODO: Implement nQueensSolutions getter
}
```

---
