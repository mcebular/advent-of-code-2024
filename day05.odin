package day05

import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"


main :: proc() {
	content, ok := os.read_entire_file("input/day05.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))

	rules: [dynamic]Rule
	updates: [dynamic][]int

	for line, i in lines {
		if strings.contains(line, "|") {
			parts := slice.mapper(
				strings.split(line, "|"),
				proc(x: string) -> int {return strconv.atoi(x)},
			)
			append(&rules, Rule{parts[0], parts[1]})
		} else if strings.contains(line, ",") {
			append(
				&updates,
				slice.mapper(
					strings.split(line, ","),
					proc(x: string) -> int {return strconv.atoi(x)},
				),
			)
		}
	}

	part_1 := 0
	part_2 := 0
	for update in updates {
		is_ok := true
		for rule in rules {
			rule_ok, _, _ := check_rule(update, rule)
			if !rule_ok {
				fixed_update := fix_update(update, rules)
				part_2 += fixed_update[len(fixed_update) / 2]
				is_ok = false
				break
			}
		}

		if is_ok {
			part_1 += update[len(update) / 2]
		}
	}

	// Part 1
	fmt.println(part_1)

	// Part 2
	fmt.println(part_2)
}

Rule :: struct {
	x: int,
	y: int,
}

check_rule :: proc(update: []int, rule: Rule) -> (bool, int, int) {
	x_pos, x_pos_found := slice.linear_search(update, rule.x)
	y_pos, y_pos_found := slice.linear_search(update, rule.y)
	if !x_pos_found || !y_pos_found {
		return true, -1, -1
	}

	return y_pos > x_pos, x_pos, y_pos
}

fix_update :: proc(update: []int, rules: [dynamic]Rule) -> []int {
	fixed_update := make([dynamic]int, len(update))
	copy(fixed_update[:], update[:])

	rule_broken := true
	for rule_broken {
		rule_broken = false
		for rule in rules {
			rule_ok, x, y := check_rule(fixed_update[:], rule)
			if !rule_ok {
				rule_broken = true
				// Move x before y.
				tmp := fixed_update[x]
				ordered_remove(&fixed_update, x)
				inject_at(&fixed_update, y, tmp)
				// Check all rules from the start.
				break
			}
		}
	}

	return fixed_update[:]
}
