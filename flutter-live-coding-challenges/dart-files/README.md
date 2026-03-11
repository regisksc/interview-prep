# Dart Fundamentals Challenges (80 exercises)

## Level 1 - Very Easy (15 exercises)

### Exercise 1: List Filter and Map

**Time**: 5 min | **Difficulty**: 1

**Description**: Given a list of integers, filter out even numbers and square the remaining odd numbers.

**Examples**:
```dart
filterAndSquare([1, 2, 3, 4, 5])  // [1, 9, 25]
filterAndSquare([2, 4, 6])        // []
filterAndSquare([])               // []
```

**Starter Code**:
```dart
List<int> filterAndSquare(List<int> numbers) {
  // TODO: Implement
}

void main() {
  print(filterAndSquare([1, 2, 3, 4, 5]));  // [1, 9, 25]
  print(filterAndSquare([2, 4, 6]));        // []
}
```

---

### Exercise 2: Find Maximum in List

**Time**: 5 min | **Difficulty**: 1

**Description**: Find the maximum value in a list without using built-in max.

**Examples**:
```dart
findMax([1, 5, 3, 9, 2])  // 9
findMax([-1, -5, -3])     // -1
findMax([42])             // 42
```

**Starter Code**:
```dart
int findMax(List<int> numbers) {
  // TODO: Implement
}
```

---

### Exercise 3: Reverse a List

**Time**: 5 min | **Difficulty**: 1

**Description**: Reverse a list without using `.reversed`.

**Examples**:
```dart
reverseList([1, 2, 3, 4])  // [4, 3, 2, 1]
reverseList([1])           // [1]
reverseList([])            // []
```

**Starter Code**:
```dart
List<T> reverseList<T>(List<T> list) {
  // TODO: Implement
}
```

---

### Exercise 4: Sum of List

**Time**: 5 min | **Difficulty**: 1

**Description**: Calculate the sum of all elements in a list.

**Examples**:
```dart
sumList([1, 2, 3, 4])  // 10
sumList([])            // 0
sumList([-1, 1])       // 0
```

**Starter Code**:
```dart
int sumList(List<int> numbers) {
  // TODO: Implement
}
```

---

### Exercise 5: Contains Duplicate

**Time**: 5 min | **Difficulty**: 1

**Description**: Check if a list contains any duplicate values.

**Examples**:
```dart
hasDuplicate([1, 2, 3, 2])  // true
hasDuplicate([1, 2, 3])     // false
hasDuplicate([])            // false
```

**Starter Code**:
```dart
bool hasDuplicate<T>(List<T> items) {
  // TODO: Implement
}
```

---

### Exercise 6: Flatten Nested List

**Time**: 10 min | **Difficulty**: 2

**Description**: Flatten a deeply nested list of integers.

**Examples**:
```dart
flatten([1, [2, 3], [4, [5, 6]]])  // [1, 2, 3, 4, 5, 6]
flatten([1, 2, 3])                  // [1, 2, 3]
flatten([])                         // []
```

**Starter Code**:
```dart
List flatten(List nested) {
  // TODO: Implement
}
```

---

### Exercise 7: Rotate List Right

**Time**: 10 min | **Difficulty**: 2

**Description**: Rotate a list to the right by k positions.

**Examples**:
```dart
rotateRight([1, 2, 3, 4, 5], 2)  // [4, 5, 1, 2, 3]
rotateRight([1, 2, 3], 1)        // [3, 1, 2]
rotateRight([1, 2, 3], 0)        // [1, 2, 3]
```

**Starter Code**:
```dart
List<T> rotateRight<T>(List<T> list, int k) {
  // TODO: Implement
}
```

---

### Exercise 8: Remove Duplicates

**Time**: 10 min | **Difficulty**: 2

**Description**: Remove duplicates from a list while preserving order.

**Examples**:
```dart
removeDuplicates([1, 2, 2, 3, 1, 4])  // [1, 2, 3, 4]
removeDuplicates([1, 1, 1])           // [1]
removeDuplicates([])                  // []
```

**Starter Code**:
```dart
List<T> removeDuplicates<T>(List<T> list) {
  // TODO: Implement
}
```

---

### Exercise 9: Two Sum

**Time**: 10 min | **Difficulty**: 2

**Description**: Find two indices that add up to a target sum.

**Examples**:
```dart
twoSum([2, 7, 11, 15], 9)    // [0, 1]
twoSum([3, 2, 4], 6)         // [1, 2]
twoSum([3, 3], 6)            // [0, 1]
```

**Starter Code**:
```dart
List<int>? twoSum(List<int> nums, int target) {
  // TODO: Implement
}
```

---

### Exercise 10: Merge Two Sorted Lists

**Time**: 10 min | **Difficulty**: 2

**Description**: Merge two sorted lists into one sorted list.

**Examples**:
```dart
mergeSorted([1, 3, 5], [2, 4, 6])  // [1, 2, 3, 4, 5, 6]
mergeSorted([1, 2], [3, 4, 5, 6])  // [1, 2, 3, 4, 5, 6]
mergeSorted([], [1, 2])            // [1, 2]
```

**Starter Code**:
```dart
List<T> mergeSorted<T extends Comparable<T>>(List<T> a, List<T> b) {
  // TODO: Implement
}
```

---

### Exercise 11: Find Second Largest

**Time**: 10 min | **Difficulty**: 2

**Description**: Find the second largest number in a list.

**Examples**:
```dart
secondLargest([1, 3, 2, 5, 4])  // 4
secondLargest([10, 10, 9])      // 9
secondLargest([5])              // null (or throw)
```

**Starter Code**:
```dart
int? secondLargest(List<int> numbers) {
  // TODO: Implement
}
```

---

### Exercise 12: Product Except Self

**Time**: 15 min | **Difficulty**: 3

**Description**: Return array where each element is product of all other elements.

**Examples**:
```dart
productExceptSelf([1, 2, 3, 4])  // [24, 12, 8, 6]
productExceptSelf([2, 3, 4])     // [12, 8, 6]
```

**Starter Code**:
```dart
List<int> productExceptSelf(List<int> nums) {
  // TODO: Implement
}
```

---

### Exercise 13: Maximum Subarray Sum

**Time**: 15 min | **Difficulty**: 3

**Description**: Find the maximum sum of contiguous subarray (Kadane's algorithm).

**Examples**:
```dart
maxSubArray([-2, 1, -3, 4, -1, 2, 1, -5, 4])  // 6 ([4,-1,2,1])
maxSubArray([1, 2, 3])                        // 6
maxSubArray([-1, -2, -3])                     // -1
```

**Starter Code**:
```dart
int maxSubArray(List<int> nums) {
  // TODO: Implement
}
```

---

### Exercise 14: Move Zeroes

**Time**: 10 min | **Difficulty**: 2

**Description**: Move all zeroes to the end while maintaining relative order.

**Examples**:
```dart
moveZeroes([0, 1, 0, 3, 12])  // [1, 3, 12, 0, 0]
moveZeroes([0, 0, 1])         // [1, 0, 0]
moveZeroes([1, 2, 3])         // [1, 2, 3]
```

**Starter Code**:
```dart
List<int> moveZeroes(List<int> nums) {
  // TODO: Implement
}
```

---

### Exercise 15: Plus One

**Time**: 10 min | **Difficulty**: 2

**Description**: Add one to a number represented as digits in a list.

**Examples**:
```dart
plusOne([1, 2, 3])  // [1, 2, 4]
plusOne([9, 9, 9])  // [1, 0, 0, 0]
plusOne([0])        // [1]
```

**Starter Code**:
```dart
List<int> plusOne(List<int> digits) {
  // TODO: Implement
}
```

---

## Level 3 - Intermediate (20 exercises)

### Exercise 16: Group Anagrams

**Time**: 15 min | **Difficulty**: 3

**Description**: Group strings that are anagrams of each other.

**Examples**:
```dart
groupAnagrams(['eat', 'tea', 'tan', 'ate', 'nat', 'bat'])
// [['eat', 'tea', 'ate'], ['tan', 'nat'], ['bat']]
```

**Starter Code**:
```dart
List<List<String>> groupAnagrams(List<String> strs) {
  // TODO: Implement
}
```

---

### Exercise 17: Three Sum

**Time**: 20 min | **Difficulty**: 3

**Description**: Find all unique triplets that sum to zero.

**Examples**:
```dart
threeSum([-1, 0, 1, 2, -1, -4])
// [[-1, -1, 2], [-1, 0, 1]]
```

**Starter Code**:
```dart
List<List<int>> threeSum(List<int> nums) {
  // TODO: Implement
}
```

---

### Exercise 18: Container With Most Water

**Time**: 15 min | **Difficulty**: 3

**Description**: Find two lines that form a container with most water.

**Examples**:
```dart
maxArea([1, 8, 6, 2, 5, 4, 8, 3, 7])  // 49
```

**Starter Code**:
```dart
int maxArea(List<int> height) {
  // TODO: Implement
}
```

---

### Exercise 19: Trapping Rain Water

**Time**: 20 min | **Difficulty**: 4

**Description**: Calculate how much water can be trapped.

**Examples**:
```dart
trap([0, 1, 0, 2, 1, 0, 1, 3, 2, 1, 2, 1])  // 6
```

**Starter Code**:
```dart
int trap(List<int> height) {
  // TODO: Implement
}
```

---

### Exercise 20: Jump Game

**Time**: 15 min | **Difficulty**: 3

**Description**: Determine if you can reach the last index.

**Examples**:
```dart
canJump([2, 3, 1, 1, 4])  // true
canJump([3, 2, 1, 0, 4])  // false
```

**Starter Code**:
```dart
bool canJump(List<int> nums) {
  // TODO: Implement
}
```

---

### Exercise 21: Merge Intervals

**Time**: 15 min | **Difficulty**: 3

**Description**: Merge overlapping intervals.

**Examples**:
```dart
mergeIntervals([[1, 3], [2, 6], [8, 10], [15, 18]])
// [[1, 6], [8, 10], [15, 18]]
```

**Starter Code**:
```dart
List<List<int>> mergeIntervals(List<List<int>> intervals) {
  // TODO: Implement
}
```

---

### Exercise 22: Insert Interval

**Time**: 15 min | **Difficulty**: 3

**Description**: Insert a new interval into sorted non-overlapping intervals.

**Examples**:
```dart
insertInterval([[1, 3], [6, 9]], [2, 5])
// [[1, 5], [6, 9]]
```

**Starter Code**:
```dart
List<List<int>> insertInterval(
    List<List<int>> intervals, List<int> newInterval) {
  // TODO: Implement
}
```

---

### Exercise 23: Spiral Matrix

**Time**: 20 min | **Difficulty**: 3

**Description**: Return elements in spiral order.

**Examples**:
```dart
spiralOrder([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
// [1, 2, 3, 6, 9, 8, 7, 4, 5]
```

**Starter Code**:
```dart
List<int> spiralOrder(List<List<int>> matrix) {
  // TODO: Implement
}
```

---

### Exercise 24: Set Matrix Zeroes

**Time**: 15 min | **Difficulty**: 3

**Description**: If element is 0, set entire row and column to 0.

**Examples**:
```dart
setZeroes([[1, 0, 3], [4, 5, 6], [7, 8, 0]])
// [[0, 0, 0], [4, 0, 0], [0, 0, 0]]
```

**Starter Code**:
```dart
void setZeroes(List<List<int>> matrix) {
  // TODO: Implement
}
```

---

### Exercise 25: Valid Sudoku

**Time**: 20 min | **Difficulty**: 3

**Description**: Validate a 9x9 Sudoku board.

**Examples**:
```dart
isValidSudoku(board)  // true or false
```

**Starter Code**:
```dart
bool isValidSudoku(List<List<String>> board) {
  // TODO: Implement
}
```

---

### Exercise 26: Rotate Image

**Time**: 15 min | **Difficulty**: 3

**Description**: Rotate n x n matrix by 90 degrees clockwise.

**Examples**:
```dart
rotate([[1, 2, 3], [4, 5, 6], [7, 8, 9]])
// [[7, 4, 1], [8, 5, 2], [9, 6, 3]]
```

**Starter Code**:
```dart
void rotate(List<List<int>> matrix) {
  // TODO: Implement
}
```

---

### Exercise 27: Word Search

**Time**: 20 min | **Difficulty**: 4

**Description**: Find if word exists in grid (adjacent cells).

**Examples**:
```dart
exist([['A','B','C','E'], ['S','F','C','S'], ['A','D','E','E']], "ABCCED")
// true
```

**Starter Code**:
```dart
bool exist(List<List<String>> board, String word) {
  // TODO: Implement
}
```

---

### Exercise 28: First Missing Positive

**Time**: 20 min | **Difficulty**: 4

**Description**: Find smallest missing positive integer.

**Examples**:
```dart
firstMissingPositive([1, 2, 0])      // 3
firstMissingPositive([3, 4, -1, 1])  // 2
firstMissingPositive([7, 8, 9])      // 1
```

**Starter Code**:
```dart
int firstMissingPositive(List<int> nums) {
  // TODO: Implement
}
```

---

### Exercise 29: Majority Element

**Time**: 10 min | **Difficulty**: 2

**Description**: Find element that appears more than n/2 times.

**Examples**:
```dart
majorityElement([3, 2, 3])           // 3
majorityElement([2, 2, 1, 1, 1, 2, 2])  // 2
```

**Starter Code**:
```dart
int majorityElement(List<int> nums) {
  // TODO: Implement
}
```

---

### Exercise 30: H-Index

**Time**: 15 min | **Difficulty**: 3

**Description**: Calculate h-index from citations.

**Examples**:
```dart
hIndex([3, 0, 6, 1, 5])  // 3
```

**Starter Code**:
```dart
int hIndex(List<int> citations) {
  // TODO: Implement
}
```

---

## Level 4 - Hard (15 exercises)

### Exercise 31: Median of Two Sorted Arrays

**Time**: 30 min | **Difficulty**: 5

**Description**: Find median of two sorted arrays in O(log(m+n)).

**Examples**:
```dart
findMedian([1, 3], [2])           // 2.0
findMedian([1, 2], [3, 4])        // 2.5
```

**Starter Code**:
```dart
double findMedianSortedArrays(List<int> nums1, List<int> nums2) {
  // TODO: Implement
}
```

---

### Exercise 32: Merge k Sorted Lists

**Time**: 25 min | **Difficulty**: 4

**Description**: Merge k sorted linked lists.

**Examples**:
```dart
mergeKLists([[1, 4, 5], [1, 3, 4], [2, 6]])
// [1, 1, 2, 3, 4, 4, 5, 6]
```

**Starter Code**:
```dart
List<int> mergeKLists(List<List<int>> lists) {
  // TODO: Implement
}
```

---

### Exercise 33: Reverse Nodes in k-Group

**Time**: 25 min | **Difficulty**: 4

**Description**: Reverse nodes in groups of k.

**Examples**:
```dart
reverseKGroup([1, 2, 3, 4, 5], 2)  // [2, 1, 4, 3, 5]
reverseKGroup([1, 2, 3, 4, 5], 3)  // [3, 2, 1, 4, 5]
```

**Starter Code**:
```dart
List<int> reverseKGroup(List<int> head, int k) {
  // TODO: Implement
}
```

---

### Exercise 34: Longest Valid Parentheses

**Time**: 20 min | **Difficulty**: 4

**Description**: Find length of longest valid parentheses substring.

**Examples**:
```dart
longestValidParentheses("(()")      // 2
longestValidParentheses(")()())")   // 4
longestValidParentheses("")         // 0
```

**Starter Code**:
```dart
int longestValidParentheses(String s) {
  // TODO: Implement
}
```

---

### Exercise 35: Next Permutation

**Time**: 20 min | **Difficulty**: 4

**Description**: Find next lexicographically greater permutation.

**Examples**:
```dart
nextPermutation([1, 2, 3])  // [1, 3, 2]
nextPermutation([3, 2, 1])  // [1, 2, 3]
nextPermutation([1, 1, 5])  // [1, 5, 1]
```

**Starter Code**:
```dart
void nextPermutation(List<int> nums) {
  // TODO: Implement
}
```

---

### Exercise 36: Search in Rotated Array

**Time**: 20 min | **Difficulty**: 4

**Description**: Search in rotated sorted array in O(log n).

**Examples**:
```dart
search([4, 5, 6, 7, 0, 1, 2], 0)  // 4
search([4, 5, 6, 7, 0, 1, 2], 3)  // -1
```

**Starter Code**:
```dart
int search(List<int> nums, int target) {
  // TODO: Implement
}
```

---

### Exercise 37: Find First and Last Position

**Time**: 20 min | **Difficulty**: 4

**Description**: Find starting and ending position of target.

**Examples**:
```dart
searchRange([5, 7, 7, 8, 8, 10], 8)  // [3, 4]
searchRange([5, 7, 7, 8, 8, 10], 6)  // [-1, -1]
```

**Starter Code**:
```dart
List<int> searchRange(List<int> nums, int target) {
  // TODO: Implement
}
```

---

### Exercise 38: Combination Sum

**Time**: 20 min | **Difficulty**: 4

**Description**: Find all unique combinations that sum to target.

**Examples**:
```dart
combinationSum([2, 3, 6, 7], 7)
// [[2, 2, 3], [7]]
```

**Starter Code**:
```dart
List<List<int>> combinationSum(List<int> candidates, int target) {
  // TODO: Implement
}
```

---

### Exercise 39: Permutations

**Time**: 20 min | **Difficulty**: 4

**Description**: Return all possible permutations.

**Examples**:
```dart
permute([1, 2, 3])
// [[1,2,3], [1,3,2], [2,1,3], [2,3,1], [3,1,2], [3,2,1]]
```

**Starter Code**:
```dart
List<List<int>> permute(List<int> nums) {
  // TODO: Implement
}
```

---

### Exercise 40: Rotate String

**Time**: 15 min | **Difficulty**: 3

**Description**: Check if string can be rotated to match another.

**Examples**:
```dart
rotateString("abcde", "cdeab")   // true
rotateString("abcde", "abced")   // false
```

**Starter Code**:
```dart
bool rotateString(String s, String goal) {
  // TODO: Implement
}
```

---

## Level 5 - Expert (10 exercises)

### Exercise 41: Regular Expression Matching

**Time**: 30 min | **Difficulty**: 5

**Description**: Implement regex matching with '.' and '*'.

**Examples**:
```dart
isMatch("aa", "a")         // false
isMatch("aa", "a*")        // true
isMatch("ab", ".*")        // true
```

**Starter Code**:
```dart
bool isMatch(String s, String p) {
  // TODO: Implement
}
```

---

### Exercise 42: Edit Distance

**Time**: 30 min | **Difficulty**: 5

**Description**: Minimum operations to convert word1 to word2.

**Examples**:
```dart
minDistance("horse", "ros")  // 3
minDistance("intention", "execution")  // 5
```

**Starter Code**:
```dart
int minDistance(String word1, String word2) {
  // TODO: Implement
}
```

---

### Exercise 43: Minimum Window Substring

**Time**: 30 min | **Difficulty**: 5

**Description**: Find minimum window containing all chars of t.

**Examples**:
```dart
minWindow("ADOBECODEBANC", "ABC")  // "BANC"
```

**Starter Code**:
```dart
String minWindow(String s, String t) {
  // TODO: Implement
}
```

---

### Exercise 44: Largest Rectangle in Histogram

**Time**: 30 min | **Difficulty**: 5

**Description**: Find largest rectangle area in histogram.

**Examples**:
```dart
largestRectangleArea([2, 1, 5, 6, 2, 3])  // 10
```

**Starter Code**:
```dart
int largestRectangleArea(List<int> heights) {
  // TODO: Implement
}
```

---

### Exercise 45: Maximal Rectangle

**Time**: 30 min | **Difficulty**: 5

**Description**: Find largest rectangle of 1s in binary matrix.

**Examples**:
```dart
maximalRectangle([
  ["1","0","1","0","0"],
  ["1","0","1","1","1"],
  ["1","1","1","1","1"],
  ["1","0","0","1","0"]
])  // 6
```

**Starter Code**:
```dart
int maximalRectangle(List<List<String>> matrix) {
  // TODO: Implement
}
```

---

### Exercise 46: Scramble String

**Time**: 30 min | **Difficulty**: 5

**Description**: Check if s2 is scrambled version of s1.

**Examples**:
```dart
isScramble("great", "rgeat")   // true
isScramble("abcde", "caebd")   // false
```

**Starter Code**:
```dart
bool isScramble(String s1, String s2) {
  // TODO: Implement
}
```

---

### Exercise 47: Interleaving String

**Time**: 30 min | **Difficulty**: 5

**Description**: Check if s3 is interleaving of s1 and s2.

**Examples**:
```dart
isInterleave("aabcc", "dbbca", "aadbbcbcac")  // true
isInterleave("aabcc", "dbbca", "aadbbbaccc")  // false
```

**Starter Code**:
```dart
bool isInterleave(String s1, String s2, String s3) {
  // TODO: Implement
}
```

---

### Exercise 48: Wildcard Matching

**Time**: 30 min | **Difficulty**: 5

**Description**: Implement wildcard matching with '?' and '*'.

**Examples**:
```dart
isMatch("aa", "a")      // false
isMatch("aa", "*")      // true
isMatch("cb", "?a")     // false
```

**Starter Code**:
```dart
bool isMatch(String s, String p) {
  // TODO: Implement
}
```

---

### Exercise 49: N-Queens

**Time**: 30 min | **Difficulty**: 5

**Description**: Solve N-Queens puzzle.

**Examples**:
```dart
solveNQueens(4)
// [[".Q..","...Q","Q...","..Q."],["..Q.","Q...","...Q",".Q.."]]
```

**Starter Code**:
```dart
List<List<String>> solveNQueens(int n) {
  // TODO: Implement
}
```

---

### Exercise 50: Sudoku Solver

**Time**: 30 min | **Difficulty**: 5

**Description**: Solve a Sudoku puzzle.

**Examples**:
```dart
solveSudoku(board)  // modifies board in place
```

**Starter Code**:
```dart
void solveSudoku(List<List<String>> board) {
  // TODO: Implement
}
```

---
