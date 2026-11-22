package main

import "core:fmt"
import "core:os"


Quantifier :: enum {
	Once,
	Zero_Or_Once,
	Zero_Or_More,
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

	for start_idx := 0; start_idx < len(text); start_idx += 1 {
		pat_idx := 0
		text_idx := start_idx
		attempt_matched := true

		for pat_idx < len(pattern) {
			atom := pattern[pat_idx]
			switch kind in atom.kind {
			case Literal:
				matches := text_idx < len(text) && kind.char == text[text_idx]
				switch atom.quantifier {
				case .Once:
					if matches {
						pat_idx += 1
						text_idx += 1

					} else do attempt_matched = false

				case .Zero_Or_Once:
					if matches do text_idx += 1
					pat_idx += 1

				case .Zero_Or_More:
					if matches do text_idx += 1
					else do pat_idx += 1
				}
			}

			if !attempt_matched do break
		}

		if attempt_matched && pat_idx == len(pattern) do return true, true
	}

	return false, true
}

is_alnum :: proc(c: u8) -> bool {
	is_alpha := (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z')
	is_num := (c >= '0' && c <= '9')

	return is_alpha || is_num

}

// TODO: Refactor to remove the repetition
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

		if c == '?' { 	// Zero_Or_Once
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

		} else if c == '*' { 	// Zero_Or_More
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

			atom.quantifier = .Zero_Or_More

		} else if is_alnum(c) { 	// Once
			atom := Atom {
				kind       = Literal{c},
				quantifier = .Once,
			}
			append(&pattern, atom)
		} else { 	// Error
			fmt.eprintln(expr)
			fmt.eprintfln("%*s ------ unknown char", i + 1, "^")
			fmt.eprintfln("Invalid regex: unknown char '%c'", c)
			return nil, false
		}

	}

	return pattern, true
}

main :: proc() {
	expr :: "a*b?c"
	texts :: [?]string{"abc", "Hello, aabc!", "aaBc", "ac", "a"}

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
