const ratio = total / 2;
const pattern = /ab+c/i;
if (ratio > 1) {
  console.log(pattern.test("abbbc"));
}

