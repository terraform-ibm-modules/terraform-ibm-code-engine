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

func setupJobsExampleOptions(t *testing.T, prefix string, terraformDir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  terraformDir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
	})
	// need to ignore because of a provider issue: https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4719
	options.IgnoreUpdates = testhelper.Exemptions{
		List: []string{
			"module.code_engine.module.job[\"" + options.Prefix + "-job\"].ibm_code_engine_job.ce_job",
			"module.code_engine.module.job[\"" + options.Prefix + "-job-2\"].ibm_code_engine_job.ce_job",
		},
	}
	options.TerraformVars = map[string]interface{}{
		"resource_group": resourceGroup,
		"prefix":         options.Prefix,
	}

	return options
}

func TestRunAppsExamplesInSchematics(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:        t,
		TemplateFolder: appsExampleDir,
		Prefix:         "ce-apps",
		TarIncludePatterns: []string{
			"*.tf",
			appsExampleDir + "/*.tf",
			"modules/app/*.tf",
			"modules/binding/*.tf",
			"modules/config_map/*.tf",
			"modules/project/*.tf",
			"modules/secret/*.tf",
			"modules/build/*.tf",
			"modules/domain_mapping/*.tf",
			"modules/job/*.tf",
		},
		ResourceGroup:          resourceGroup,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 60,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "resource_group", Value: options.ResourceGroup, DataType: "string"},
		{Name: "prefix", Value: options.Prefix + "-app", DataType: "string"},
		{Name: "existing_sm_instance_guid", Value: permanentResources["secretsManagerGuid"], DataType: "string"},
		{Name: "existing_sm_instance_region", Value: permanentResources["secretsManagerRegion"], DataType: "string"},
		{Name: "ca_name", Value: permanentResources["certificateAuthorityName"], DataType: "string"},
		{Name: "dns_provider_name", Value: permanentResources["dnsProviderName"], DataType: "string"},
		{Name: "region", Value: options.Region, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}

func TestRunJobsExample(t *testing.T) {
	t.Parallel()

	options := setupJobsExampleOptions(t, "ce-jobs", jobsExampleDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunAppSolutionInSchematics(t *testing.T) {
	t.Parallel()

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing:        t,
		TemplateFolder: appsSolutionsDir,
		Prefix:         "ce-da",
		TarIncludePatterns: []string{
			"*.tf",
			appsSolutionsDir + "/*.tf",
			"modules/app/*.tf",
			"modules/binding/*.tf",
			"modules/config_map/*.tf",
			"modules/project/*.tf",
			"modules/secret/*.tf",
			"modules/build/*.tf",
			"modules/domain_mapping/*.tf",
			"modules/job/*.tf",
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
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
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
	t.Parallel()

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  appsSolutionsDir,
		Prefix:        "ce-app-upg",
		ResourceGroup: resourceGroup,
	})
	// need to ignore because of a provider issue: https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4719
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
		"provider_visibility":     "public",
		"prefix":                  options.Prefix,
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

func TestUpgradeCEProjectDA(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: "solutions/project",
		Prefix:       "ce-da",
	})

	options.TerraformVars = map[string]interface{}{
		"resource_group_name":     resourceGroup,
		"existing_resource_group": true,
		"provider_visibility":     "public",
		"prefix":                  options.Prefix,
		"project_name":            "test-1",
	}

	output, err := options.RunTestUpgrade()

	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestDeployCEProjectDA(t *testing.T) {
	t.Parallel()

	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: "solutions/project",
		Prefix:       "ce-da",
	})

	options.TerraformVars = map[string]interface{}{
		"resource_group_name":     resourceGroup,
		"existing_resource_group": true,
		"prefix":                  options.Prefix,
		"provider_visibility":     "public",
		"project_name":            "test-1",
	}

	output, err := options.RunTestConsistency()

	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
