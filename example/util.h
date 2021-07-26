
/* Function to sort an array arr1 using insertion sort
 * Mirror the placements in arr2 */
void insertionSort(uint64_t arr1[], long arr2[], int n) {
  int i, key, elem, j;
  for (i = 1; i < n; i++) {
    key = arr1[i];
    elem = arr2[i];
    j = i - 1;

    /* Move elements of arr1[0..i-1], that are
      greater than key, to one position ahead
      of their current position */
    while (j >= 0 && arr1[j] > key) {
      arr1[j + 1] = arr1[j];
      arr2[j + 1] = arr2[j];
      j = j - 1;
    }
    arr1[j + 1] = key;
    arr2[j + 1] = elem;
  }
}
