package day09

import "core:fmt"
import "core:os"
import "core:slice"
import "core:strconv"
import "core:strings"

main :: proc() {
	content, ok := os.read_entire_file("input/day09.txt")
	if !ok {
		// could not read file
		return
	}
	defer delete(content)

	disk_map := slice.mapper(
		strings.split(strings.split_lines(string(content))[0], ""),
		proc(s: string) -> int {return strconv.atoi(s)},
	)
	space_sum := slice.reduce(disk_map, 0, proc(a, n: int) -> int {return a + n})
	disk := make([]int, space_sum)
	disk_idx := 0
	file_id := 0
	free_space := false
	for i in disk_map {
		for j in 0 ..< i {
			if free_space {
				disk[disk_idx + j] = -1
			} else {
				disk[disk_idx + j] = file_id
			}
		}
		if !free_space {
			file_id += 1
		}
		disk_idx += i
		free_space = !free_space
	}

	// Part 1
	fmt.println(checksum(rearrange_1(disk)))

	// Part 2
	fmt.println(checksum(rearrange_2(disk)))
}

rearrange_1 :: proc(_disk: []int) -> []int {
	disk := make([]int, len(_disk))
	copy_slice(disk[:], _disk[:])

	end_idx := len(disk) - 1
	for curr_idx in 0 ..< len(disk) {
		for disk[end_idx] == -1 {
			end_idx -= 1
		}
		if curr_idx >= end_idx {
			break
		}
		if disk[curr_idx] == -1 {
			disk[curr_idx] = disk[end_idx]
			disk[end_idx] = -1
		}
	}

	return disk
}

rearrange_2 :: proc(_disk: []int) -> []int {
	disk := make([]int, len(_disk))
	copy_slice(disk[:], _disk[:])

	for i := len(disk) - 1; i > 0; i -= 1 {
		fid := disk[i]
		if fid == -1 {
			continue
		}

		file_end := i
		file_start := i
		for file_start >= 0 && disk[file_start] == disk[file_end] {
			file_start -= 1
		}
		file_start += 1
		file_end += 1
		file_size := file_end - file_start

		for j := 0; j < i; j += 1 {
			if disk[j] != -1 {
				continue
			}

			free_start := j
			free_end := j
			for disk[free_start] == disk[free_end] {
				free_end += 1
			}
			free_end -= 1
			free_size := free_end - free_start + 1

			if free_size >= file_size {
				copy_slice(disk[free_start:free_end + 1], disk[file_start:file_end])
				for k in file_start ..< file_end {
					disk[k] = -1
				}
				break
			}
		}

		i -= file_size - 1
	}

	return disk
}

checksum :: proc(disk: []int) -> int {
	result := 0
	for id, idx in disk {
		if id == -1 {
			continue
		}
		result += (idx * id)
	}
	return result
}
