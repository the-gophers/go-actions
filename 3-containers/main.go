package main

import (
	"fmt"
	"log"
	"net/http"
	"net/http/httputil"
	"os"
)

func main() {
	web()
}

func web() {
	http.HandleFunc("/", httpHello)
	http.HandleFunc("/echo", httpEcho)
	http.HandleFunc("/host", httpHost)
	listenPort := ":80"
	if val := os.Getenv("LISTEN_PORT"); val != "" {
		listenPort = ":" + val
	}
	fmt.Printf("Listening on %s\n", listenPort)
	err := http.ListenAndServe(listenPort, httpLog(http.DefaultServeMux))
	if err != nil {
		log.Fatal(err)
	}
}

func httpHello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello Gopher!\n")
}

func httpEcho(w http.ResponseWriter, r *http.Request) {
	b, err := httputil.DumpRequest(r, true)
	if err != nil {
		log.Printf("Error: %s\n", b)
		return
	}
	log.Printf("%s\n", b)
	fmt.Fprintf(w, "%s", b)
}

func httpHost(w http.ResponseWriter, r *http.Request) {
	if hostname, err := os.Hostname(); err == nil {
		fmt.Fprintf(w, "Hostname: %s\n", hostname)
	}
}

func httpLog(handler http.Handler) http.Handler {
	return http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			log.Printf("%s %s %s\n", r.RemoteAddr, r.Method, r.URL)
			handler.ServeHTTP(w, r)
		})
}
