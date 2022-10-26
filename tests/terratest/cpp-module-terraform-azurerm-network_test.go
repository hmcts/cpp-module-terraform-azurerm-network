package test

import (
	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
	"path/filepath"
	"strings"
	"testing"
)

//Testing the secure-file-transfer Module
func TestTerraformNetworks(t *testing.T) {
	t.Parallel()


	// Region set as uksouth as standard.
	azureRegion := "uksouth"

	// Hard wire this to the "Strategic Platform - non-live" subscription
	azureSbscrptn := "8cdb5405-7535-4349-92e9-f52bddc7833a"

	// Terraform plan.out File Path
	exampleFolder := test_structure.CopyTerraformFolderToTemp(t, "../..", "examples/for_terratests")
	planFilePath := filepath.Join(exampleFolder, "plan.out")


	// set up variables for other module variables so assertions may be made on them later
	expectedEnvironment := "dev"
	expectedRole := "terratests"
	expectedLocation := "uksouth"
	expectedPlatform := "nl"
	expectedTier := "testing"

	expectedVnetAddrSpace := "10.1.0.0/16"
	expectedVnetName := "vn" + "-" +
		strings.ToLower(expectedEnvironment) + "-" +
		strings.ToLower(expectedRole) + "-" + "01"

	expectedRgName := "rg" + "-" +
		strings.ToLower(expectedEnvironment) + "-" +
		strings.ToLower(expectedRole) + "-" + "01"

	/* To be expanded upon if required

	expectedDmzSbntName := "sn" + "-" +
		strings.ToLower(expectedEnvironment) + "-" +
		strings.ToLower(expectedRole) + "-" + "dmz"

	expectedMngtSbntName := "sn" + "-" +
		strings.ToLower(expectedEnvironment) + "-" +
		strings.ToLower(expectedRole) + "-" + "mngt"

	expectedGwSbntName := "gws" + "-" +
		strings.ToLower(expectedEnvironment) + "-" +
		strings.ToLower(expectedRole) + "-" + "01"

	expectedFwSbntName := "fws" + "-" +
		strings.ToLower(expectedEnvironment) + "-" +
		strings.ToLower(expectedRole) + "-" + "01"

	expectedDnsZnName := "dz" + "-" +
		strings.ToLower(expectedEnvironment) + "-" +
		strings.ToLower(expectedRole) + "-" + "01.local"
	*/

	// Pre-Checks
	// First establish that the intended VNET & Resource Group do NOT already exist
	// We wish to avoid any false negatives (stubbed, however worth putting in place
	_, err := azure.GetVirtualNetworkE(expectedVnetName, azureRegion, azureSbscrptn)
	if err == nil {
		t.Fatalf("Function claimed that VNET '%s' exists, but in fact it should not.", expectedVnetName)
	}

	_, err2 := azure.ResourceGroupExistsE(expectedRgName, "")
	if err2 == nil {
		t.Fatalf("Function claimed that Resource Group '%s' exists, but in fact it should not.", expectedRgName)
	}

	// Add more for other independent Resources where possible eg Resource Group, DNS etc


	terraformPlanOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../../examples/for_terratests",
		Upgrade:      true,

		// Variables to pass to our Terraform code using -var options
		VarFiles: []string{"for_terratest.tfvars"},

		//Environment variables to set when running Terraform

		// Configure a plan file path so we can inspect the plan and make assertions about it.
		PlanFilePath: planFilePath,
	})

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformPlanOptions)

	// Run terraform init plan and show and fail the test if there are any errors
	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformPlanOptions)

	// Run `terraform init` and `terraform apply`. Fail the test if there are any errors.
	terraform.InitAndApply(t, terraformPlanOptions)

	// Run `terraform output` to get the values of output variables
	vnetName := terraform.Output(t, terraformPlanOptions, "virtual_network_name")
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedVnetName, vnetName)

	vnetAddrSpace := terraform.Output(t, terraformPlanOptions, "virtual_network_address_space")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, vnetAddrSpace, expectedVnetAddrSpace )

	rgName := terraform.Output(t, terraformPlanOptions, "resource_group_name")
	// Verify we're getting back the output we expect
	assert.Equal(t, expectedRgName, rgName)

	rgLctn := terraform.Output(t, terraformPlanOptions, "resource_group_location")
	// Verify we're getting back the output we expect
	assert.Equal(t, expectedLocation, rgLctn)

	dnsZn := terraform.Output(t, terraformPlanOptions, "dns_zone_id")
	// Verify we're getting back "a" value back for this
	assert.NotNil(t, dnsZn)
	
	// Check that Tagging is applied Correctly (Check each relevant Resource)

	// VNET Tagging
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.vnet.azurerm_virtual_network.vnet")
	vnetResource := plan.ResourcePlannedValuesMap["module.vnet.azurerm_virtual_network.vnet"]
	vnetTags := vnetResource.AttributeValues["tags"].(map[string]interface{})
	// Verify that we have the mandatory set of Tags attached
	assert.Equal(t, expectedEnvironment, vnetTags["environment"], "Environment tag should match Environment")
	assert.Equal(t, expectedRole, vnetTags["role"], "Role tag should match role")
	assert.Equal(t, expectedPlatform, vnetTags["platform"], "Platform tag should match platform")
	assert.Equal(t, expectedTier, vnetTags["tier"], "Tier tag should match Tier")

	// DMZ Network Security Group Tagging
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.vnet.azurerm_network_security_group.nsg[\"dmz_subnet\"]")
	dmzNsg := plan.ResourcePlannedValuesMap["module.vnet.azurerm_network_security_group.nsg[\"dmz_subnet\"]"]
	dmzNsgTags := dmzNsg.AttributeValues["tags"].(map[string]interface{})
	// Verify that we have the mandatory set of Tags attached
	assert.Equal(t, expectedEnvironment, dmzNsgTags["environment"], "Environment tag should match Environment")
	assert.Equal(t, expectedRole, dmzNsgTags["role"], "Role tag should match role")
	assert.Equal(t, expectedPlatform, dmzNsgTags["platform"], "Platform tag should match platform")
	assert.Equal(t, expectedTier, dmzNsgTags["tier"], "Tier tag should match Tier")

	// Mngt Subnet Network Security Group Tagging
	terraform.RequirePlannedValuesMapKeyExists(t, plan, "module.vnet.azurerm_network_security_group.nsg[\"mgnt_subnet\"]")
	mngtNsg := plan.ResourcePlannedValuesMap["module.vnet.azurerm_network_security_group.nsg[\"mgnt_subnet\"]"]
	mngtNsgTags := mngtNsg.AttributeValues["tags"].(map[string]interface{})
	// Verify that we have the mandatory set of Tags attached
	assert.Equal(t, expectedEnvironment, mngtNsgTags["environment"], "Environment tag should match Environment")
	assert.Equal(t, expectedRole, mngtNsgTags["role"], "Role tag should match role")
	assert.Equal(t, expectedPlatform, mngtNsgTags["platform"], "Platform tag should match platform")
	assert.Equal(t, expectedTier, mngtNsgTags["tier"], "Tier tag should match Tier")

	// Add more tests as required
	// Tests should be reviewed as the module evolves
}
