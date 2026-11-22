package main

import "core:fmt"
import "core:os"


match_regex :: proc(re, target: string) -> (matched: bool, ok: bool) {
	if len(re) <= 0 {
		fmt.eprintln("Invalid regex: an empty string is not a valid regex")
		return false, false
	}

	re_i := 0
	target_i := 0

	for re_i < len(re) {
		if target_i >= len(target) do return false, true

		if re[re_i] != target[target_i] {
			if re_i == 0 do target_i += 1
			re_i = 0
			continue
		}

		re_i += 1
		target_i += 1
	}

	return true, true
}

main :: proc() {
	re := "abc"
	target := "Hello, aabc!"

	matched, ok := match_regex(re, target)
	if !ok do os.exit(1)

	fmt.println("re =", re)
	fmt.println("target =", target)
	fmt.println("matched =", matched)
}
