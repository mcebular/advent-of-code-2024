package day13

import "core:fmt"
import "core:math"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:text/regex"

main :: proc() {
	content, ok := os.read_entire_file("input/day13.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))

	rx_a, _ := regex.create_by_user("/Button A: X\\+(\\d+), Y\\+(\\d+)/g")
	rx_b, _ := regex.create_by_user("/Button B: X\\+(\\d+), Y\\+(\\d+)/g")
	rx_p, _ := regex.create_by_user("/Prize: X=(\\d+), Y=(\\d+)/g")

	machines := make([dynamic]Machine)
	ma, mb, mp: Vec2
	for line in lines {
		match_rx_a, match_found_rx_a := regex.match(rx_a, line)
		if (match_found_rx_a) {
			ma = Vec2 {
				strconv.atoi(line[match_rx_a.pos[1][0]:match_rx_a.pos[1][1]]),
				strconv.atoi(line[match_rx_a.pos[2][0]:match_rx_a.pos[2][1]]),
			}
			continue
		}

		match_rx_b, match_found_rx_b := regex.match(rx_b, line)
		if (match_found_rx_b) {
			mb = Vec2 {
				strconv.atoi(line[match_rx_b.pos[1][0]:match_rx_b.pos[1][1]]),
				strconv.atoi(line[match_rx_b.pos[2][0]:match_rx_b.pos[2][1]]),
			}
			continue
		}

		match_rx_p, match_found_rx_p := regex.match(rx_p, line)
		if (match_found_rx_p) {
			mp = Vec2 {
				strconv.atoi(line[match_rx_p.pos[1][0]:match_rx_p.pos[1][1]]),
				strconv.atoi(line[match_rx_p.pos[2][0]:match_rx_p.pos[2][1]]),
			}
			continue
		}

		append(&machines, Machine{ma, mb, mp})
	}

	// Part 1
	fmt.println(total_tokens(machines))

	// Part 2
	fmt.println(total_tokens(machines, true))
}

Vec2 :: struct {
	x: int,
	y: int,
}

Machine :: struct {
	a: Vec2,
	b: Vec2,
	p: Vec2,
}

total_tokens :: proc(machines: [dynamic]Machine, part2: bool = false) -> int {
	total_tokens := 0
	for machine in machines {
		// Initial formulas:
		// (1): a * x1 + b * x2 = x3
		// (2): a * y1 + b * y2 = y3
		//
		// Extract b out of (1):
		// b = (x3 - a * x1) / x2
		//
		// Use b from above in (2), extract a:
		// a * y1 + ((x3 - a * x1) / x2) * y2 = y3
		// a * y1 * x2 + (x3 - a * x1) * y2 = y3 * x2
		// a * y1 * x2 + y2 * x3 - y2 * a * x1 = y3 * x2
		// a * y1 * x2 - y2 * a * x1 = y3 * x2 - y2 * x3
		// a (y1 * x2 - y2 * x1) = y3 * x2 - y2 * x3
		// a = (y3 * x2 - y2 * x3) / (y1 * x2 - y2 * x1)

		x1 := machine.a.x
		x2 := machine.b.x
		x3 := machine.p.x
		y1 := machine.a.y
		y2 := machine.b.y
		y3 := machine.p.y

		if part2 {
			x3 += 10000000000000
			y3 += 10000000000000
		}

		a, ar := math.divmod(y3 * x2 - y2 * x3, y1 * x2 - y2 * x1)
		if ar != 0 {
			continue
		}
		b, br := math.divmod(x3 - a * x1, x2)
		if br != 0 {
			continue
		}

		total_tokens += a * 3 + b * 1
	}

	return total_tokens
}
