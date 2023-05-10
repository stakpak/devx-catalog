package v1

getMatch: {
	match: string
	input: [string]: _
	result: (input & {"\(match)": _})["\(match)"]
}
