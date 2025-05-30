package main

import (
	"html/template"
	"log"
	"net/http"
)

func main() {
	// Serve static files
	http.Handle("/static/", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))
	
	// Handle the home page
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		tmpl := template.Must(template.ParseFiles("templates/index.html"))
		tmpl.Execute(w, nil)
	})

	log.Println("Server starting on http://localhost:6001")
	log.Fatal(http.ListenAndServe(":6001", nil))
} 