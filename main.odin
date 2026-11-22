package main

import "core:fmt"
import "core:os"


Quantifier :: enum {
	Once,
	Zero_Or_Once,
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

		atom := pattern[pat_idx]
		switch kind in atom.kind {
		case Literal:
			matched := kind.char == text[text_idx]
			switch atom.quantifier {
			case .Once:
				if matched {
					pat_idx += 1
					text_idx += 1

				} else {
					if pat_idx == 0 do text_idx += 1
					pat_idx = 0
				}

			case .Zero_Or_Once:
				if matched do text_idx += 1
				pat_idx += 1
			}
		}
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

		if c == '?' {
			if len(pattern) == 0 {
				fmt.eprintln(expr)
				fmt.eprintfln("%*s ------ illegal quantifier", i + 1, "^")
				fmt.eprintfln("Illegal quantifier '?'")
				return nil, false
			}

			atom := &pattern[len(pattern) - 1]
			if atom.quantifier != .Once {
				fmt.eprintln(expr)
				fmt.eprintfln("%*s ------ illegal quantifier", i + 1, "^")
				fmt.eprintfln("Illegal quantifier '?'")
				return nil, false
			}

			atom.quantifier = .Zero_Or_Once
			continue
		}

		if !is_alnum(c) {
			fmt.eprintln(expr)
			fmt.eprintfln("%*s ------ unknown char", i + 1, "^")
			fmt.eprintfln("Invalid regex: unknown char '%c'", c)
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
	expr :: "ab?c"
	texts :: [?]string{"abc", "Hello, aabc!", "aaBc", "ac"}

	pattern, ok := compile(expr)
	if !ok do os.exit(1)
	defer delete(pattern)

	fmt.println("pattern =", pattern[:])
	for text in texts {
		matched, ok := is_match(pattern[:], text)
		if !ok do os.exit(1)

		fmt.println("expr =", expr)
		fmt.println("text =", text)
		fmt.println("matched =", matched)
		fmt.println()
	}
}
