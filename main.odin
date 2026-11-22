package main

import "core:fmt"
import "core:os"


Quantifier :: enum {
	Once,
}

Literal :: struct {
	char: u8,
}

Atom :: struct {
	kind:       union {
		Literal,
	},
	quantifier: Quantifier,
}

is_match :: proc(pattern: []Atom, text: string) -> (matched: bool, ok: bool) {
	if len(pattern) <= 0 {
		fmt.eprintln("Invalid regex: an empty array is not a valid expression")
		return false, false
	}

	pat_idx := 0
	text_idx := 0

	for pat_idx < len(pattern) {
		if text_idx >= len(text) do return false, true

		switch unit in pattern[pat_idx].kind {
		case Literal:
			if unit.char != text[text_idx] {
				if pat_idx == 0 do text_idx += 1
				pat_idx = 0
				continue
			}

		}

		pat_idx += 1
		text_idx += 1
	}

	return true, true
}

is_alnum :: proc(c: u8) -> bool {
	is_alpha := (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
	is_num := (c >= '0' && c <= '9')

	return is_alpha || is_num

}

compile :: proc(expr: string) -> ([dynamic]Atom, bool) {
	if len(expr) <= 0 {
		fmt.eprintln("Invalid regex: an empty string is not a valid regex")
		return nil, false
	}

	pattern := make([dynamic]Atom)

	i := 0
	for i < len(expr) {
		defer i += 1

		c := expr[i]
		if !is_alnum(c) {
			fmt.eprintfln("Invalid regex: unknown char '%c' at '%d'", c, i)
			return nil, false
		}

		atom := Atom {
			kind       = Literal{c},
			quantifier = .Once,
		}
		append(&pattern, atom)
	}

	return pattern, true
}

main :: proc() {
	expr :: "abc"
	texts :: [?]string{"abc", "Hello, aabc!", "aaBc"}

	pattern, ok := compile(expr)
	if !ok do os.exit(1)
	defer delete(pattern)

	for text in texts {
		matched, ok := is_match(pattern[:], text)
		if !ok do os.exit(1)

		fmt.println("expr =", expr)
		fmt.println("text =", text)
		fmt.println("matched =", matched)
		fmt.println()
	}
}
