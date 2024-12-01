package day01

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	content, ok := os.read_entire_file("input/day01.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))

	l1 := make([]int, len(lines))
	l2 := make([]int, len(lines))

	for line, i in lines {
		nums := strings.split(line, "   ")
		l1[i] = strconv.atoi(nums[0])
		l2[i] = strconv.atoi(nums[1])
	}

	slice.sort(l1)
	slice.sort(l2)

	diff := 0
	for i in 0 ..< len(l1) {
		diff += abs(l1[i] - l2[i])
	}

	// Part 1
	fmt.println(diff)

	sim := 0
	for i in 0 ..< len(l1) {
		times := 0
		num := l1[i]
		for j in 0 ..< len(l2) {
			if (num == l2[j]) {
				times += 1
			}
		}
		sim += num * times
	}

	// Part 2
	fmt.println(sim)
}
