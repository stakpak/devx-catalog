package v2alpha1

#Taskfile: {
	version: "3"
	output:  *"interleaved" | "group" | "prefixed"
	method:  *"checksum" | "timestamp" | "none"
	includes: [string]: #Include
	vars: [string]:     #Variable
	env: [string]:      #Variable
	tasks: [string]:    #Task
	silent: bool | *false
	dotenv: [...string]
	run:      *"always" | "once" | "when_changed"
	interval: string | *"5s"
	set: [...string]
	shopt: [...string]
}

#Include: {
	taskfile: string
	dir?:     string
	optional: bool | *false
	internal: bool | *false
	aliases: [...string]
	vars: [string]: #Variable
} | string

#Task: {
	cmds: [...#Command]
	deps: [...#Dependency]
	label?:   string
	desc?:    string
	summary?: string
	aliases: [...string]
	sources: [...string]
	generates: [...string]
	status: [...string]
	preconditions: [...#Precondition]
	dir?: string
	vars: [string]: #Variable
	env: [string]:  #Variable
	dotenv: [...string]
	silent:       bool | *false
	interactive:  bool | *false
	internal:     bool | *false
	method:       *"checksum" | "timestamp" | "none"
	prefix?:      string
	ignore_error: bool | *false
	run:          *"always" | "once" | "when_changed"
	platforms: [...string]
	set: [...string]
	shopt: [...string]
} | string

#Dependency: {
	task: string
	vars: [string]: #Variable
} | string

#Command: {
	cmd?:   string
	silent: bool | *false
	task?:  string
	vars: [string]: #Variable
	ignore_error: bool | *false
	defer?:       string
	platforms: [...string]
	set: [...string]
	shopt: [...string]
} | string

#Variable: {
	sh: string
} | string

#Precondition: {
	sh:   string
	msg?: string
} | string
