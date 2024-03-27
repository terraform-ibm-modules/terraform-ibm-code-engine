// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

const useSubmoduleExampleDir = "examples/use-submodule"

func setupOptionsUseSubmodule(t *testing.T, prefix string, terraformDir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  terraformDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
	})
	options.IgnoreUpdates = testhelper.Exemptions{
		List: []string{
			"module.ce_app[\"" + options.Prefix + "-app-1\"].ibm_code_engine_app.ce_app",
			"module.ce_app[\"" + options.Prefix + "-app-2\"].ibm_code_engine_app.ce_app",
		},
	}
	options.TerraformVars = map[string]interface{}{
		"resource_group": resourceGroup,
		"prefix":         options.Prefix,
	}

	return options
}

func TestRunUseSubmoduleExample(t *testing.T) {
	t.Parallel()

	options := setupOptionsUseSubmodule(t, "ce-use-submodule", useSubmoduleExampleDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
