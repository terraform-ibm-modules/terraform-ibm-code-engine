// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"log"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
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
	// need to ignore because of a provider issue: https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4719
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

func TestRunAppsExample(t *testing.T) {
	t.Parallel()

	options := setupAppsExampleOptions(t, "ce-apps", appsExampleDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
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

	// Provision watsonx Assistant instance
	prefix := fmt.Sprintf("ce-data-%s", strings.ToLower(random.UniqueId()))
	realTerraformDir := ".."
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))
	// tags := common.GetTagsFromTravis()

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir + "/tests/resources",
		Vars: map[string]interface{}{
			"resource_group":              resourceGroup,
			"prefix":                      prefix,
			"existing_sm_instance_guid":   permanentResources["secretsManagerGuid"],
			"existing_sm_instance_region": permanentResources["secretsManagerRegion"],
			"existing_cert_secret_id":     permanentResources["cePublicCertId"],
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
	} else {
		outputs, err := terraform.OutputAllE(t, existingTerraformOptions)
		require.NoError(t, err, "Failed to retrieve Terraform outputs")
		expectedOutputs := []string{"tls_cert", "tls_key", "cr_name"}
		_, tfOutputsErr := testhelper.ValidateTerraformOutputs(outputs, expectedOutputs...)
		if assert.Nil(t, tfOutputsErr, tfOutputsErr) {
			options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
				Testing:      t,
				TerraformDir: "solutions/project",
				// Do not hard fail the test if the implicit destroy steps fail to allow a full destroy of resource to occur
				ImplicitRequired: false,
				TerraformVars: map[string]interface{}{
					"prefix":                  prefix,
					"provider_visibility":     "public",
					"project_name":            prefix,
					"resource_group_name":     resourceGroup,
					"existing_resource_group": true,
					"builds": map[string]interface{}{
						fmt.Sprintf("%s-build", prefix): map[string]interface{}{
							"output_image":  fmt.Sprintf("us.icr.io/%s/%s", terraform.Output(t, existingTerraformOptions, "cr_name"), prefix),
							"output_secret": fmt.Sprintf("%s-registry", prefix), // pragma: allowlist secret
							"source_url":    "https://github.com/IBM/CodeEngine",
							"strategy_type": "dockerfile",
						},
					},
					"config_maps": map[string]interface{}{
						fmt.Sprintf("%s-cm", prefix): map[string]interface{}{
							"data": map[string]interface{}{
								"key_1": "value_1",
								"key_2": "value_2",
							},
						},
					},
					"secrets": map[string]interface{}{
						fmt.Sprintf("%s-tls", prefix): map[string]interface{}{
							"format": "tls",
							"data": map[string]string{
								"tls_cert": strings.ReplaceAll(terraform.Output(t, existingTerraformOptions, "tls_cert"), "\n", `\n`),
								"tls_key":  strings.ReplaceAll(terraform.Output(t, existingTerraformOptions, "tls_key"), "\n", `\n`),
							},
						},
						fmt.Sprintf("%s-registry", prefix): map[string]interface{}{
							"format": "registry",
							"data": map[string]string{
								"server":   "us.icr.io",
								"username": "iamapikey",
								"password": val, // pragma: allowlist secret
							},
						},
					},
				},
			})
			output, err := options.RunTestConsistency()
			assert.Nil(t, err, "This should not have errored")
			assert.NotNil(t, output, "Expected some output")
		}
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (existing resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (existing resources)")
	}
}
