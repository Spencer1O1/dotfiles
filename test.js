// Form factory

const createForm = (data) => {
  const form = document.createElement("form");
  Object.entries(data).forEach(([key, value]) => {
    const input = document.createElement("input");
    input.type = "text";
    input.name = key;
    input.value = value;
    form.appendChild(input);
  });
  return form;
};

const quicksort = (array) => {
  if (array.length <= 1) {
    return array;
  }
  const pivot = array[0];
  const left = [];
  const right = [];
  for (let i = 1; i < array.length; i++) {
    if (array[i] < pivot) {
      left.push(array[i]);
    } else {
      right.push(array[i]);
    }
  }
  return [...quicksort(left), pivot, ...quicksort(right)];
};

// mixed up array
const array = [2, 9, 3, 6, 5, 4, 7, 8, 1, 10];
const sorted = quicksort(array);

if (
  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].every(
    (value, index) => value === sorted[index],
  )
) {
  console.log("sorted");
}
