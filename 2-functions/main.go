package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/http/httputil"
	"os"
)

func main() {
	if err := run(); err != nil {
		log.Fatalf("%s\n", err)
	}
}

func run() error {
	http.HandleFunc("/", httpDefault)
	http.HandleFunc("/healthz", httpHealth)
	http.HandleFunc("/HttpTrigger", httpTrigger)
	http.HandleFunc("/TimerTrigger", httpTimerTrigger)
	http.HandleFunc("/api/hello", httpHello)
	http.HandleFunc("/api/", httpEcho)
	http.HandleFunc("/auth/", httpEcho)

	listenAddr := ":80"
	if val := os.Getenv("LISTEN_PORT"); val != "" {
		listenAddr = ":" + val
	}
	if val := os.Getenv("FUNCTIONS_HTTPWORKER_PORT"); val != "" {
		listenAddr = ":" + val
	}
	fmt.Printf("Listening on %s\n", listenAddr)
	return http.ListenAndServe(listenAddr, httpLog(http.DefaultServeMux))
}

func httpLog(handler http.Handler) http.Handler {
	return http.HandlerFunc(
		func(w http.ResponseWriter, r *http.Request) {
			log.Printf("%s %s %s\n", r.RemoteAddr, r.Method, r.URL)
			handler.ServeHTTP(w, r)
		})
}

func httpDefault(w http.ResponseWriter, r *http.Request) {
	http.NotFound(w, r)
}

func httpHealth(w http.ResponseWriter, r *http.Request) {
	serverName := "hello-gopher"
	if val := os.Getenv("SERVER_NAME"); val != "" {
		serverName = val
	}
	fmt.Fprintf(w, serverName)
}

func httpHello(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello API!\n")
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

func httpTrigger(w http.ResponseWriter, r *http.Request) {
	entity := "Functions"
	if val := r.FormValue("name"); val != "" {
		entity = val
	}
	fmt.Fprintf(w, "Hello %s!\n", entity)
}

func httpTimerTrigger(w http.ResponseWriter, r *http.Request) {
	defer r.Body.Close()
	b, _ := ioutil.ReadAll(r.Body)
	log.Printf("TimerTrigger: %s", b)
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprintf(w, "{}")
}
