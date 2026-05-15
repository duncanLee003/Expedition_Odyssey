extends Node

signal updated

var artifacts := {}

func add_artifact(id: String):
	if artifacts.has(id):
		return

	artifacts[id] = true
	updated.emit()
