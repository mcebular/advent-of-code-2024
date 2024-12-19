package day19

import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	content, ok := os.read_entire_file("input/day19.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))

	patterns := new(map[string]bool)
	max_pattern_length := 0
	for p in strings.split(lines[0], ", ") {
		patterns[p] = true
		max_pattern_length = math.max(max_pattern_length, len(p))
	}
	towels := lines[2:]

	composable_1 := 0
	composable_2 := 0
	for towel, idx in towels {
		mem := new(map[string]int)
		defer delete(mem^)
		count := compose(towel, max_pattern_length, patterns, mem)
		// fmt.println(idx, towel, count)
		if count > 0 {
			composable_1 += 1
		}
		composable_2 += count
	}

	// Part 1
	fmt.println(composable_1)

	// Part 2
	fmt.println(composable_2)
}

compose :: proc(
	remaining: string,
	max_pattern_length: int,
	patterns: ^map[string]bool,
	mem: ^map[string]int,
) -> int {
	if len(remaining) == 0 {
		return 1
	}

	if remaining in mem {
		return mem[remaining]
	}

	count := 0
	for i in 1 ..< math.min(len(remaining), max_pattern_length) + 1 {
		slice := remaining[0:i]
		if slice in patterns {
			count += compose(remaining[i:], max_pattern_length, patterns, mem)
		}
	}

	mem[remaining] = count
	return count
}
