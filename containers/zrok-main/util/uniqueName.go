package util

import (
	goaway "github.com/TwiN/go-away"
	"regexp"
)

// IsValidUniqueName ensures that the string represents a valid unique name. Lowercase alphanumeric only. 4-32 characters.
func IsValidUniqueName(uniqueName string) bool {
	match, err := regexp.Match("^[a-z0-9]{4,32}$", []byte(uniqueName))
	if err != nil {
		return false
	}
	if match && goaway.IsProfane(uniqueName) {
		return false
	}
	return match
}
