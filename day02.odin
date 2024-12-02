package day02

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	content, ok := os.read_entire_file("input/day02.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))

	reports := make([][]int, len(lines))

	for line, i in lines {
		reports[i] = slice.mapper(
			strings.split(line, " "),
			proc(x: string) -> int {return strconv.atoi(x)},
		)
	}

	safe_reports_count_1 := 0
	for report in reports {
		if is_safe(report) {
			safe_reports_count_1 += 1
		}
	}

	// Part 1
	fmt.println(safe_reports_count_1)

	safe_reports_count_2 := 0
	for report in reports {
		for i in 0 ..< len(report) {
			// remove element at i
			x: [dynamic]int
			append(&x, ..report[0:i])
			append(&x, ..report[i + 1:len(report)])

			if is_safe(x[:]) {
				safe_reports_count_2 += 1
				break
			}
		}
	}

	// Part 2
	fmt.println(safe_reports_count_2)
}

is_safe :: proc(report: []int) -> bool {
	increasing := report[0] < report[1]

	for i in 1 ..< len(report) {
		prev := report[i - 1]
		curr := report[i]
		diff := curr - prev
		if increasing {
			if !(diff > 0 && diff < 4) {
				return false
			}
		} else { 	// decreasing
			if !(diff < 0 && diff > -4) {
				return false
			}
		}
	}

	return true
}
