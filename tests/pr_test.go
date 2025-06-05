// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"bytes"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
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
const projectSolutionsDir = "solutions/project"

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
		{Name: "existing_resource_group_name", Value: options.ResourceGroup, DataType: "string"},
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
		"ibmcloud_api_key":             options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"],
		"existing_resource_group_name": resourceGroup,
		"app_name":                     options.Prefix + "-app",
		"image_reference":              "icr.io/codeengine/helloworld",
		"provider_visibility":          "public",
		"prefix":                       options.Prefix,
		"secrets":                      "{" + options.Prefix + "-secret:{format:\"generic\", data:{ key_1 : \"value_1\" }}}", // pragma: allowlist secret
		"config_maps":                  "{" + options.Prefix + "-cm:{data:{ key_1 : \"value_1\" }}}",
		"project_name":                 options.Prefix + "-pro",
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
		TerraformDir: projectSolutionsDir,
		Prefix:       "ce-da",
	})

	options.TerraformVars = map[string]interface{}{
		"existing_resource_group_name": resourceGroup,
		"provider_visibility":          "public",
		"prefix":                       options.Prefix,
		"project_name":                 "test-1",
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

		cr_name, _ := getTerraformOutput(tempTerraformDir+"/tests/resources", "cr_name")
		tls_cert, _ := getTerraformOutput(tempTerraformDir+"/tests/resources", "tls_cert")
		tls_key, _ := getTerraformOutput(tempTerraformDir+"/tests/resources", "tls_key")

		tfVars := map[string]interface{}{
			"prefix":                       prefix,
			"provider_visibility":          "public",
			"project_name":                 prefix,
			"existing_resource_group_name": resourceGroup,
			"container_registry_namespace": cr_name,
			"builds": map[string]interface{}{
				fmt.Sprintf("%s-build", prefix): map[string]interface{}{
					"output_image":  fmt.Sprintf("private.us.icr.io/%s/%s", cr_name, prefix),
					"output_secret": fmt.Sprintf("%s-registry", prefix), // pragma: allowlist secret
					"source_url":    "https://github.com/IBM/CodeEngine",
					"strategy_type": "dockerfile",
				},
				fmt.Sprintf("%s-build-2", prefix): map[string]interface{}{
					"output_secret":      fmt.Sprintf("%s-registry", prefix), // pragma: allowlist secret
					"source_url":         "https://github.com/IBM/CodeEngine",
					"strategy_type":      "dockerfile",
					"source_context_dir": "hello",
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
						"tls_cert": strings.ReplaceAll(tls_cert, "\n", `\n`),
						"tls_key":  strings.ReplaceAll(tls_key, "\n", `\n`),
					},
				},
				fmt.Sprintf("%s-registry", prefix): map[string]interface{}{
					"format": "registry",
					"data": map[string]string{
						"server":   "private.us.icr.io",
						"username": "iamapikey",
						"password": val, // pragma: allowlist secret
					},
				},
			},
		}

		tfvarsPath := tempTerraformDir + "/solutions/project/terraform.auto.tfvars"
		writeTfvarsFile(t, tfvarsPath, tfVars)
		if err := os.Remove(tfvarsPath); err != nil {
			log.Printf("Warning: failed to remove %s: %v\n", tfvarsPath, err)
		}

		options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: tempTerraformDir + "/solutions/project",
		})

		cleanTerraformCache(tempTerraformDir + "/solutions/project")
		terraform.WorkspaceSelectOrNew(t, options, prefix)
		output, existErr := terraform.InitAndApplyE(t, options)
		if existErr != nil {
			assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
		}

		assert.Nil(t, existErr, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
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

func getTerraformOutput(dir, name string) (string, error) {
	cmd := exec.Command("terraform", "output", "-no-color", name)
	cmd.Dir = dir

	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &out

	err := cmd.Run()
	if err != nil {
		return "", err
	}

	// Trim and unquote if needed
	raw := strings.TrimSpace(out.String())

	// If heredoc-style, strip the surrounding <<EOT ... EOT markers
	heredocPattern := regexp.MustCompile(`(?s)^<<EOT\n(.*)\nEOT$`)
	if matches := heredocPattern.FindStringSubmatch(raw); matches != nil {
		return matches[1], nil // only return the actual content
	}

	unquoted, err := strconv.Unquote(raw)
	if err != nil {
		// If unquoting fails (e.g. already unquoted), just return raw
		return raw, nil
	}
	return unquoted, nil
}

func cleanTerraformCache(dir string) {
	terraformFilesAndDirectories := []string{
		".terraform",
		".terraform.lock.hcl",
		"terraform.tfstate",
		"terraform.tfstate.backup",
	}
	for _, fileName := range terraformFilesAndDirectories {
		fullPath := filepath.Join(dir, fileName)
		if _, err := os.Stat(fullPath); err == nil {
			// Path exists → remove (dir or file)
			if err := os.RemoveAll(fullPath); err != nil {
				// Ignore errors, just log them
				log.Printf("Error removing file %s: %s", fileName, err)
			}
		} else if !os.IsNotExist(err) {
			// Ignore errors, just log them
			log.Printf("Error removing file %s: %s", fileName, err)
		}
	}
}

func toHCL(value interface{}, indentLevel int) string {
	indent := strings.Repeat("  ", indentLevel)

	switch val := value.(type) {
	case string:
		return fmt.Sprintf("\"%s\"", val)
	case bool:
		return fmt.Sprintf("%t", val)
	case float64, int:
		return fmt.Sprintf("%v", val)
	case map[string]string:
		var b strings.Builder
		b.WriteString("{\n")
		keys := make([]string, 0, len(val))
		for k := range val {
			keys = append(keys, k)
		}
		sort.Strings(keys)
		for _, k := range keys {
			b.WriteString(fmt.Sprintf("%s  %s = \"%s\"\n", indent, k, val[k]))
		}
		b.WriteString(fmt.Sprintf("%s}", indent))
		return b.String()
	case map[string]interface{}:
		var b strings.Builder
		b.WriteString("{\n")
		keys := make([]string, 0, len(val))
		for k := range val {
			keys = append(keys, k)
		}
		sort.Strings(keys)
		for _, k := range keys {
			b.WriteString(fmt.Sprintf("%s  \"%s\" = %s\n", indent, k, toHCL(val[k], indentLevel+1)))
		}
		b.WriteString(fmt.Sprintf("%s}", indent))
		return b.String()
	default:
		return fmt.Sprintf("\"%v\"", val)
	}
}

func writeTfvarsFile(t *testing.T, path string, vars map[string]interface{}) {
	var sb strings.Builder
	for k, v := range vars {
		sb.WriteString(fmt.Sprintf("%s = %s\n", k, toHCL(v, 0)))
	}

	err := os.WriteFile(path, []byte(sb.String()), 0644)
	if err != nil {
		t.Fatalf("Failed to write tfvars file: %v", err)
	}
}
