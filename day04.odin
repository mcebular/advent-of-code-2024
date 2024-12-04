package day04

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strings"


main :: proc() {
	content, ok := os.read_entire_file("input/day04.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))

	crossword := make([][]rune, len(lines))

	for line, i in lines {
		crossword[i] = slice.mapper(
			strings.split(line, ""),
			proc(x: string) -> rune {return rune(x[0])},
		)
	}

	xmas_count := 0
	x_mas_count := 0
	for y in 0 ..< len(crossword) {
		line := crossword[y]
		for x in 0 ..< len(line) {
			// horizontal
			if (is_xmas(
					   crossword,
					   [4][2]int {
						   [2]int{x, y},
						   [2]int{x + 1, y},
						   [2]int{x + 2, y},
						   [2]int{x + 3, y},
					   },
				   )) {
				xmas_count += 1
			}
			// horizontal-reverse
			if (is_xmas(
					   crossword,
					   [4][2]int {
						   [2]int{x, y},
						   [2]int{x - 1, y},
						   [2]int{x - 2, y},
						   [2]int{x - 3, y},
					   },
				   )) {
				xmas_count += 1
			}
			// vertical
			if (is_xmas(
					   crossword,
					   [4][2]int {
						   [2]int{x, y},
						   [2]int{x, y + 1},
						   [2]int{x, y + 2},
						   [2]int{x, y + 3},
					   },
				   )) {
				xmas_count += 1
			}
			// vertical-reverse
			if (is_xmas(
					   crossword,
					   [4][2]int {
						   [2]int{x, y},
						   [2]int{x, y - 1},
						   [2]int{x, y - 2},
						   [2]int{x, y - 3},
					   },
				   )) {
				xmas_count += 1
			}
			// diagonal (se)
			if (is_xmas(
					   crossword,
					   [4][2]int {
						   [2]int{x, y},
						   [2]int{x + 1, y + 1},
						   [2]int{x + 2, y + 2},
						   [2]int{x + 3, y + 3},
					   },
				   )) {
				xmas_count += 1
			}
			// diagonal (sw)
			if (is_xmas(
					   crossword,
					   [4][2]int {
						   [2]int{x, y},
						   [2]int{x - 1, y + 1},
						   [2]int{x - 2, y + 2},
						   [2]int{x - 3, y + 3},
					   },
				   )) {
				xmas_count += 1
			}
			// diagonal (ne)
			if (is_xmas(
					   crossword,
					   [4][2]int {
						   [2]int{x, y},
						   [2]int{x + 1, y - 1},
						   [2]int{x + 2, y - 2},
						   [2]int{x + 3, y - 3},
					   },
				   )) {
				xmas_count += 1
			}
			// diagonal (nw)
			if (is_xmas(
					   crossword,
					   [4][2]int {
						   [2]int{x, y},
						   [2]int{x - 1, y - 1},
						   [2]int{x - 2, y - 2},
						   [2]int{x - 3, y - 3},
					   },
				   )) {
				xmas_count += 1
			}

			// horizontal
			if (is_x_mas(
					   crossword,
					   [5][2]int {
						   [2]int{x, y},
						   [2]int{x - 1, y - 1},
						   [2]int{x - 1, y + 1},
						   [2]int{x + 1, y - 1},
						   [2]int{x + 1, y + 1},
					   },
				   )) {
				x_mas_count += 1
			}
			// horizontal-reverse
			if (is_x_mas(
					   crossword,
					   [5][2]int {
						   [2]int{x, y},
						   [2]int{x + 1, y - 1},
						   [2]int{x + 1, y + 1},
						   [2]int{x - 1, y - 1},
						   [2]int{x - 1, y + 1},
					   },
				   )) {
				x_mas_count += 1
			}
			// vertical
			if (is_x_mas(
					   crossword,
					   [5][2]int {
						   [2]int{x, y},
						   [2]int{x - 1, y - 1},
						   [2]int{x + 1, y - 1},
						   [2]int{x - 1, y + 1},
						   [2]int{x + 1, y + 1},
					   },
				   )) {
				x_mas_count += 1
			}
			// vertical-reverse
			if (is_x_mas(
					   crossword,
					   [5][2]int {
						   [2]int{x, y},
						   [2]int{x - 1, y + 1},
						   [2]int{x + 1, y + 1},
						   [2]int{x - 1, y - 1},
						   [2]int{x + 1, y - 1},
					   },
				   )) {
				x_mas_count += 1
			}
		}
	}

	// Part 1
	fmt.println(xmas_count)

	// Part 2
	fmt.println(x_mas_count)
}

is_xmas :: proc(cw: [][]rune, p: [4][2]int) -> bool {
	xx := p[0][0]
	xy := p[0][1]
	mx := p[1][0]
	my := p[1][1]
	ax := p[2][0]
	ay := p[2][1]
	sx := p[3][0]
	sy := p[3][1]

	if xx < 0 ||
	   xx >= len(cw[0]) ||
	   mx < 0 ||
	   mx >= len(cw[0]) ||
	   ax < 0 ||
	   ax >= len(cw[0]) ||
	   sx < 0 ||
	   sx >= len(cw[0]) {
		// out of bounds
		return false
	}

	if xy < 0 ||
	   xy >= len(cw) ||
	   my < 0 ||
	   my >= len(cw) ||
	   ay < 0 ||
	   ay >= len(cw) ||
	   sy < 0 ||
	   sy >= len(cw) {
		// out of bounds
		return false
	}

	if cw[xy][xx] == 'X' && cw[my][mx] == 'M' && cw[ay][ax] == 'A' && cw[sy][sx] == 'S' {
		return true
	}

	return false
}

is_x_mas :: proc(cw: [][]rune, p: [5][2]int) -> bool {
	ax := p[0][0]
	ay := p[0][1]
	m1x := p[1][0]
	m1y := p[1][1]
	m2x := p[2][0]
	m2y := p[2][1]
	s1x := p[3][0]
	s1y := p[3][1]
	s2x := p[4][0]
	s2y := p[4][1]

	if ax < 0 ||
	   ax >= len(cw[0]) ||
	   m1x < 0 ||
	   m1x >= len(cw[0]) ||
	   m2x < 0 ||
	   m2x >= len(cw[0]) ||
	   s1x < 0 ||
	   s1x >= len(cw[0]) ||
	   s2x < 0 ||
	   s2x >= len(cw[0]) {
		// out of bounds
		return false
	}

	if ay < 0 ||
	   ay >= len(cw) ||
	   m1y < 0 ||
	   m1y >= len(cw) ||
	   m2y < 0 ||
	   m2y >= len(cw) ||
	   s1y < 0 ||
	   s1y >= len(cw) ||
	   s2y < 0 ||
	   s2y >= len(cw) {
		// out of bounds
		return false
	}

	if cw[ay][ax] == 'A' &&
	   cw[m1y][m1x] == 'M' &&
	   cw[m2y][m2x] == 'M' &&
	   cw[s1y][s1x] == 'S' &&
	   cw[s2y][s2x] == 'S' {
		return true
	}

	return false
}
