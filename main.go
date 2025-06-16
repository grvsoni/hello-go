package main

import (
	"html/template"
	"log"
	"net/http"
	"os"
)

func main() {
	// Serve static files
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))
	
	// Handle the home page
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// Get hostname which will be the pod name in Kubernetes
		hostname, err := os.Hostname()
		if err != nil {
			hostname = "Unknown"
		}
		
		// Create data map to pass to template
		data := map[string]interface{}{
			"PodName": hostname,
		}
		
		tmpl := template.Must(template.ParseFiles("templates/index.html"))
		tmpl.Execute(w, data)
	})

	log.Println("Server starting on http://localhost:6001")
	log.Fatal(http.ListenAndServe(":6001", nil))
} 