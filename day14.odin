package day14

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"
import "core:text/regex"

main :: proc() {
	content, ok := os.read_entire_file("input/day14.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))

	rx, _ := regex.create_by_user("/p=(-?\\d+),(-?\\d+) v=(-?\\d+),(-?\\d+)/g")

	map_width := 101
	map_height := 103
	robots := make([dynamic]Robot)
	for line in lines {
		match_rx, match_found_rx := regex.match(rx, line)
		if !match_found_rx {
			fmt.println("Invalid input:", line)
			os.exit(1)
		}

		append(
			&robots,
			Robot {
				Vec2 {
					strconv.atoi(line[match_rx.pos[1][0]:match_rx.pos[1][1]]),
					strconv.atoi(line[match_rx.pos[2][0]:match_rx.pos[2][1]]),
				},
				Vec2 {
					strconv.atoi(line[match_rx.pos[3][0]:match_rx.pos[3][1]]),
					strconv.atoi(line[match_rx.pos[4][0]:match_rx.pos[4][1]]),
				},
			},
		)
	}

	seconds := 100
	for &robot in robots {
		robot.p.x = (robot.p.x + robot.v.x * seconds) %% map_width
		robot.p.y = (robot.p.y + robot.v.y * seconds) %% map_height
	}

	quadrants := make(map[int]int)
	quadrants[0] = 0
	quadrants[1] = 0
	quadrants[2] = 0
	quadrants[3] = 0
	for robot in robots {
		quadrants[which_quadrant(robot, map_width, map_height)] += 1
	}

	// Part 1
	fmt.println(quadrants[0] * quadrants[1] * quadrants[2] * quadrants[3])

	// Figured this one out by printing the map each second. At 105 seconds,
	// the map had a... specific layout that could hint towards the solution.
	// This layout repeated every 101 seconds (105, 206, ...), so I was 
	// printing the map every 101 seconds until I came to the solution for my 
	// input: 6771.
	seconds = 6771 - 100
	for &robot in robots {
		robot.p.x = (robot.p.x + robot.v.x * seconds) %% map_width
		robot.p.y = (robot.p.y + robot.v.y * seconds) %% map_height
	}
	// print_map(robots, map_width, map_height)

	// Part 2
	fmt.println("* 6771")
}

Vec2 :: struct {
	x: int,
	y: int,
}

Robot :: struct {
	p: Vec2,
	v: Vec2,
}

which_quadrant :: proc(robot: Robot, width: int, height: int) -> int {
	if robot.p.x < width / 2 && robot.p.y < height / 2 {
		return 0
	} else if robot.p.x > width / 2 && robot.p.y < height / 2 {
		return 1
	} else if robot.p.x < width / 2 && robot.p.y > height / 2 {
		return 2
	} else if robot.p.x > width / 2 && robot.p.y > height / 2 {
		return 3
	} else {
		return -1
	}
}

print_map :: proc(robots: [dynamic]Robot, width: int, height: int) {
	robot_positions := make(map[Vec2]int)
	for robot in robots {
		robot_positions[robot.p] += 1
	}

	for y in 0 ..< height {
		for x in 0 ..< width {
			if (Vec2{x, y} in robot_positions) {
				fmt.print(robot_positions[Vec2{x, y}])
			} else {
				fmt.print(" ")
			}
		}
		fmt.println()
	}
}
