package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestHello(t *testing.T) {
	t.Run("api/hello", func(t *testing.T) {
		request, _ := http.NewRequest(http.MethodGet, "/api/hello", nil)
		response := httptest.NewRecorder()

		httpHello(response, request)

		got := response.Body.String()
		want := "Hello API!\n"

		if got != want {
			t.Errorf("got %q, want %q", got, want)
		}
	})
}
