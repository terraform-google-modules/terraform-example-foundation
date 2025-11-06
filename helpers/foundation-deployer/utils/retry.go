package utils

import (
	"fmt"
	"regexp"

	"github.com/terraform-google-modules/terraform-example-foundation/test/integration/testutils"

	"github.com/mitchellh/go-testing-interface"
)

var (
	retryRegexp = map[*regexp.Regexp]string{}
)

func init() {
	for e, m := range testutils.RetryableTransientErrors {
		r, err := regexp.Compile(fmt.Sprintf("(?s)%s", e)) //(?s) enables dot (.) to match newline.
		if err != nil {
			panic(fmt.Sprintf("failed to compile regex %s: %s", e, err.Error()))
		}
		retryRegexp[r] = m
	}
}

// IsRetryableError checks the logs of a failed execution
// and verify if the error is a transient one and can be retried
func IsRetryableError(t testing.TB, logs string) bool {
	found := false
	for pattern, msg := range retryRegexp {
		if pattern.MatchString(logs) {
			found = true
			fmt.Printf("error '%s' is worth of a retry\n", msg)
			break
		}
	}
	return found
}
