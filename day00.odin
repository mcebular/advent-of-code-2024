package day00

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	name := os.args[1]
	fmt.println("Hello, ", name, "!")

	data, ok := os.read_entire_file_from_filename("input/day00.txt", context.allocator)
	if !ok {
		// could not read file
		return
	}
	defer delete(data, context.allocator)

	it := string(data)
	for line in strings.split_lines_iterator(&it) {
		fmt.println(line)
	}
}
