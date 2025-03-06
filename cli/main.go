package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"os/exec"
)

// Embed the Python script directly into the binary
var pythonScript string

type CVEResult struct {
	URL           string      `json:"url"`
	ServerVersion string      `json:"server_version"`
	CVEs          interface{} `json:"cves"` // Alterado para interface{}
	Error         string      `json:"error,omitempty"`
	Timestamp     string      `json:"timestamp"`
}

func main() {
	// Parse CLI arguments
	url := flag.String("url", "", "URL of the website to analyze")
	flag.Parse()

	if *url == "" {
		fmt.Println("Error: URL is required.")
		fmt.Println("Usage: ./hawkcve -url <URL>")
		return
	}

	// Write the embedded Python script to a temporary file
	tmpFile := "hawkcve_temp.py"
	err := os.WriteFile(tmpFile, []byte(pythonScript), 0644)
	if err != nil {
		fmt.Println("Error creating temporary Python script:", err)
		return
	}
	defer os.Remove(tmpFile) // Clean up the temporary file

	// Execute the Python script
	cmd := exec.Command("python3", tmpFile, *url)
	output, err := cmd.CombinedOutput() // Captura stdout e stderr
	if err != nil {
		fmt.Println("Error executing Python script:", err)
		fmt.Println("Python script output:", string(output)) // Exibe a saída do script Python
		return
	}

	// Decode the JSON output from the Python script
	var result CVEResult
	if err := json.Unmarshal(output, &result); err != nil {
		fmt.Println("Error decoding JSON:", err)
		fmt.Println("Raw Python script output:", string(output)) // Exibe a saída bruta do script Python
		return
	}

	// Display the results
	if result.Error != "" {
		fmt.Println("Error:", result.Error)
		return
	}

	fmt.Println("=== Analysis Results ===")
	fmt.Printf("URL: %s\n", result.URL)
	fmt.Printf("Server Version: %s\n", result.ServerVersion)
	fmt.Printf("Analysis Timestamp: %s\n", result.Timestamp)
	fmt.Println("CVEs Found:")

	// Verifica se cves é uma lista ou um objeto de erro
	switch cves := result.CVEs.(type) {
	case []interface{}: // Se for uma lista de CVEs
		if len(cves) == 0 {
			fmt.Println("  - No CVEs found.")
			return
		}
		for _, cve := range cves {
			if cveMap, ok := cve.(map[string]interface{}); ok {
				fmt.Printf("  - ID: %s\n", cveMap["id"])
				fmt.Printf("    Description: %s\n", cveMap["summary"])
				fmt.Printf("    Published: %s\n", cveMap["Published"])
				fmt.Println("    ---")
			}
		}
	case map[string]interface{}: // Se for um objeto de erro
		if errorMsg, ok := cves["error"].(string); ok {
			fmt.Println("  -", errorMsg)
		} else {
			fmt.Println("  - No CVEs found.")
		}
	default:
		fmt.Println("  - No CVEs found.")
	}
}
