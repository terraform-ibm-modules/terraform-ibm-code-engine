// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

// Use existing resource group
const resourceGroup = "geretain-test-resources"
const appsExampleDir = "examples/apps"
const jobsExampleDir = "examples/jobs"
const appsSolutionsDir = "solutions/apps"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func setupAppsExampleOptions(t *testing.T, prefix string, terraformDir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  terraformDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
	})
	options.IgnoreUpdates = testhelper.Exemptions{
		List: []string{
			"module.code_engine.module.app[\"" + options.Prefix + "-app\"].ibm_code_engine_app.ce_app",
			"module.code_engine.module.app[\"" + options.Prefix + "-app2\"].ibm_code_engine_app.ce_app",
		},
	}
	options.TerraformVars = map[string]interface{}{
		"resource_group":              resourceGroup,
		"prefix":                      options.Prefix,
		"existing_sm_instance_guid":   permanentResources["secretsManagerGuid"],
		"existing_sm_instance_region": permanentResources["secretsManagerRegion"],
		"existing_cert_secret_id":     permanentResources["cePublicCertId"],
		"existing_cert_common_name":   "goldeneye.dev.cloud.ibm.com",
	}

	return options
}

func setupJobsExampleOptions(t *testing.T, prefix string, terraformDir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  terraformDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
	})
	options.TerraformVars = map[string]interface{}{
		"resource_group": resourceGroup,
		"prefix":         options.Prefix,
	}

	return options
}

func TestRunAppsExample(t *testing.T) {
	t.Skip()
	t.Parallel()

	options := setupAppsExampleOptions(t, "ce-apps", appsExampleDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunJobsExample(t *testing.T) {
	t.Skip()
	t.Parallel()

	options := setupJobsExampleOptions(t, "ce-jobs", jobsExampleDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

// func TestRunAppsSolution(t *testing.T) {
// 	t.Skip()
// 	t.Parallel()

// 	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
// 		Testing:       t,
// 		TerraformDir:  appsSolutionsDir,
// 		Prefix:        "ce-app-solutions",
// 		ResourceGroup: resourceGroup,
// 	})

// 	options.IgnoreUpdates = testhelper.Exemptions{
// 		List: []string{
// 			"module.code_engine.module.app[\"" + options.Prefix + "-app\"].ibm_code_engine_app.ce_app",
// 		},
// 	}
// 	options.TerraformVars = map[string]interface{}{
// 		"ibmcloud_api_key":        options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"],
// 		"resource_group_name":     resourceGroup,
// 		"existing_resource_group": true,
// 		"app_name":                options.Prefix + "-app",
// 		"image_reference":         "icr.io/codeengine/helloworld",
// 		"secrets":                 "{" + options.Prefix + "-secret:{format:\"generic\", data:{ key_1 : \"value_1\" }}}", // pragma: allowlist secret
// 		"config_maps":             "{" + options.Prefix + "-cm:{data:{ key_1 : \"value_1\" }}}",
// 		"project_name":            options.Prefix + "-pro",
// 	}

// 	output, err := options.RunTestConsistency()
// 	assert.Nil(t, err, "This should not have errored")
// 	assert.NotNil(t, output, "Expected some output")
// }

func TestRunAppSolutionInSchematics(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:        t,
		TemplateFolder: appsSolutionsDir,
		Prefix:         "ce-da",
		TarIncludePatterns: []string{
			"*.tf",
			appsSolutionsDir + "/*.tf",
		},
		ResourceGroup:          resourceGroup,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "resource_group_name", Value: options.ResourceGroup, DataType: "string"},
		{Name: "existing_resource_group", Value: true, DataType: "bool"},
		{Name: "app_name", Value: options.Prefix + "-app", DataType: "string"},
		{Name: "image_reference", Value: "icr.io/codeengine/helloworld", DataType: "string"},
		{Name: "secrets", Value: "{" + options.Prefix + "-secret:{format:\"generic\", data:{ key_1 : \"value_1\" }}}", DataType: "object"}, // pragma: allowlist secret
		{Name: "config_maps", Value: "{" + options.Prefix + "-cm:{data:{ key_1 : \"value_1\" }}}", DataType: "object"},
		{Name: "project_name", Value: options.Prefix + "-pro", DataType: "string"},
		{Name: "region", Value: options.Region, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunUpgradeAppSolution(t *testing.T) {
	t.Skip()
	t.Parallel()

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  appsSolutionsDir,
		Prefix:        "ce-app-upg",
		ResourceGroup: resourceGroup,
	})

	options.IgnoreUpdates = testhelper.Exemptions{
		List: []string{
			"module.code_engine.module.app[\"" + options.Prefix + "-app\"].ibm_code_engine_app.ce_app",
		},
	}
	options.TerraformVars = map[string]interface{}{
		"ibmcloud_api_key":        options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"],
		"resource_group_name":     resourceGroup,
		"existing_resource_group": true,
		"app_name":                options.Prefix + "-app",
		"image_reference":         "icr.io/codeengine/helloworld",
		"secrets":                 "{" + options.Prefix + "-secret:{format:\"generic\", data:{ key_1 : \"value_1\" }}}", // pragma: allowlist secret
		"config_maps":             "{" + options.Prefix + "-cm:{data:{ key_1 : \"value_1\" }}}",
		"project_name":            options.Prefix + "-pro",
	}

	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}
