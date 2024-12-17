package day17

import "core:fmt"
import "core:math"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	content, ok := os.read_entire_file("input/day17.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	lines := strings.split_lines(string(content))
	device := Device {
		strconv.atoi(strings.split(lines[0], ": ")[1]),
		strconv.atoi(strings.split(lines[1], ": ")[1]),
		strconv.atoi(strings.split(lines[2], ": ")[1]),
		slice.mapper(
			strings.split(strings.split(lines[4], ": ")[1], ","),
			proc(s: string) -> int {return strconv.atoi(s)},
		),
		0,
		make([dynamic]int),
	}

	device1 := device
	execute(&device1)

	// Part 1
	fmt.println(output(device1))

	// Basically I was doing big iter skips, i.e. (iter += 100_000_000) until
	// I got about half (right half) of the program fixed to correct numbers,
	// then I let it run with (iter += 1) to find the exact match.
	iter := 247839002890238
	for true {
		device_i := device
		device_i.A = iter
		execute(&device_i)

		if output(device_i) == program(device_i) {
			break
		}

		iter += 1
	}

	// Part 2
	fmt.println("*", iter)
}

Device :: struct {
	A, B, C: int,
	program: []int,
	ip:      int,
	output:  [dynamic]int,
}

execute :: proc(device: ^Device) {
	for true {
		if (device.ip >= len(device.program)) {
			break
		}

		instruction := device.program[device.ip]
		operand := device.program[device.ip + 1]
		operand_value := operand
		if (operand == 4) {
			operand_value = device.A
		} else if (operand == 5) {
			operand_value = device.B
		} else if (operand == 6) {
			operand_value = device.C
		} else if (operand == 7) {}

		device.ip += 2

		switch instruction {
		case 0:
			// adv
			numerator := device.A
			denominator := int(math.pow(2, f16(operand_value)))
			device.A = numerator / denominator
		case 1:
			// bxl
			device.B = device.B ~ operand
		case 2:
			// bst
			device.B = operand_value %% 8
		case 3:
			// jnz
			if device.A != 0 {
				device.ip = operand
			}
		case 4:
			// bxc
			device.B = device.B ~ device.C
		case 5:
			// out
			output := operand_value %% 8
			append(&device.output, output)
		case 6:
			// bdv
			numerator := device.A
			denominator := int(math.pow(2, f16(operand_value)))
			device.B = numerator / denominator
		case 7:
			// cdv
			numerator := device.A
			denominator := int(math.pow(2, f16(operand_value)))
			device.C = numerator / denominator
		}
	}
}

output :: proc(device: Device) -> string {
	result := ""
	for o, i in device.output {
		result = strings.concatenate({result, fmt.aprint(o)})
		if i < len(device.output) - 1 {
			result = strings.concatenate({result, ","})
		}
	}
	return result
}

program :: proc(device: Device) -> string {
	result := ""
	for o, i in device.program {
		result = strings.concatenate({result, fmt.aprint(o)})
		if i < len(device.program) - 1 {
			result = strings.concatenate({result, ","})
		}
	}
	return result
}
