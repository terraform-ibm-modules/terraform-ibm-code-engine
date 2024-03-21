// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

const useSubmoduleExampleDir = "examples/use-submodule"

func TestRunUseSubmoduleExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "ce-use-submodule", useSubmoduleExampleDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
