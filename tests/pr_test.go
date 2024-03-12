// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const basicExampleDir = "examples/basic"

func setupOptions(t *testing.T, prefix string, terraformDir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  terraformDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		IgnoreUpdates: testhelper.Exemptions{
			List: []string{
				"module.code_engine.ibm_code_engine_app.ce_app[0]",
				"module.code_engine.ibm_code_engine_app.ce_app[1]",
			},
		},
	})
	options.TerraformVars = map[string]interface{}{
		"resource_group": resourceGroup,
		"prefix":         options.Prefix,
	}

	return options
}

func TestRunBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "ce-basic", basicExampleDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeBasicExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "ce-upg", basicExampleDir)

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
