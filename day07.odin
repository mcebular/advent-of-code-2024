package day07

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"


main :: proc() {
	content, ok := os.read_entire_file("input/day07.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))

	equations := make([]Equation, len(lines))
	for line, i in lines {
		parts := strings.split(line, ": ")
		equations[i] = Equation {
			strconv.atoi(parts[0]),
			slice.mapper(
				strings.split(parts[1], " "),
				proc(s: string) -> int {return strconv.atoi(s)},
			),
		}
	}

	// Part 1
	fmt.println(calibration_result(equations, false))

	// Part 2
	fmt.println(calibration_result(equations, true))
}

Equation :: struct {
	result:   int,
	operands: []int,
}

calibration_result :: proc(equations: []Equation, allow_concat: bool = false) -> int {
	result := 0
	for equation in equations {
		if is_solvable(
			equation.result,
			equation.operands[0],
			equation.operands[1:],
			allow_concat,
		) {
			result += equation.result
		}

	}
	return result
}

is_solvable :: proc(
	expected_result: int,
	current_result: int,
	remaining_operands: []int,
	allow_concat: bool,
) -> bool {
	if len(remaining_operands) == 0 {
		return expected_result == current_result
	}

	if is_solvable(
		expected_result,
		current_result + remaining_operands[0],
		remaining_operands[1:],
		allow_concat,
	) {
		return true
	} else if is_solvable(
		expected_result,
		current_result * remaining_operands[0],
		remaining_operands[1:],
		allow_concat,
	) {
		return true
	} else if allow_concat {
		return is_solvable(
			expected_result,
			int_concat(current_result, remaining_operands[0]),
			remaining_operands[1:],
			allow_concat,
		)
	} else {
		return false
	}
}

int_concat :: proc(i1: int, i2: int) -> int {
	return strconv.atoi(fmt.aprintf("%d%d", i1, i2))
}
